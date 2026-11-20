import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:encrypted_drift/encrypted_drift.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'encryption_key.dart';
import 'tables.dart';

part 'voice_database.g.dart';

@DriftDatabase(
  tables: [Recordings, TranscriptSegments, Folders, Tags, Settings, Exports],
)
class VoiceDatabase extends _$VoiceDatabase {
  VoiceDatabase._(super.executor);

  factory VoiceDatabase.forTesting(QueryExecutor executor) =>
      VoiceDatabase._(executor);

  static Future<VoiceDatabase> open() async {
    final key = await EncryptionKeyStore().readOrCreate();
    final documents = await getApplicationDocumentsDirectory();
    final databaseFile = File(p.join(documents.path, 'voice_recorder.sqlite'));
    await databaseFile.parent.create(recursive: true);
    final database = VoiceDatabase._(
      EncryptedExecutor(path: databaseFile.path, password: key),
    );
    await database.customSelect('PRAGMA user_version').get();
    if (Platform.isIOS) {
      const storageChannel = MethodChannel('com.locvel.voite/storage');
      await storageChannel.invokeMethod<void>(
        'protectAppData',
        <String, Object>{'path': databaseFile.parent.path},
      );
      await storageChannel.invokeMethod<void>(
        'protectAppData',
        <String, Object>{'path': databaseFile.path},
      );
    }
    return database;
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createSearchIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(recordings, recordings.isFavorite);
      }
      if (from < 3) {
        await migrator.addColumn(recordings, recordings.label);
        await _migrateRecordingLabels();
      }
      if (from < 4) {
        await migrator.addColumn(recordings, recordings.prompt);
        await migrator.addColumn(recordings, recordings.diaryEdited);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _createSearchIndexes();
    },
  );

  Future<void> _migrateRecordingLabels() async {
    final labels = <String>{'Voice note', 'Lecture', 'Meeting', 'Idea'};
    final storedLabels =
        await (select(settings)..where(
              (setting) => setting.settingKey.equals('recording_custom_labels'),
            ))
            .getSingleOrNull();
    if (storedLabels != null) {
      try {
        final decoded = jsonDecode(storedLabels.value);
        if (decoded is List) labels.addAll(decoded.whereType<String>());
      } on FormatException {
        // Keep existing recordings under the default label if legacy data is invalid.
      }
    }
    final rows = await select(recordings).get();
    for (final row in rows) {
      final oldLabel = labels
          .where((label) => row.title.startsWith('$label · '))
          .fold<String?>(null, (longest, label) {
            if (longest == null || label.length > longest.length) return label;
            return longest;
          });
      if (oldLabel == null) continue;
      await (update(recordings)
            ..where((recording) => recording.id.equals(row.id)))
          .write(RecordingsCompanion(label: Value(oldLabel)));
    }
  }

  Future<void> _createSearchIndexes() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS transcript_segments_fts
      USING fts5(transcript_text, content='transcript_segments', content_rowid='rowid')
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS transcript_segments_fts_insert
      AFTER INSERT ON transcript_segments BEGIN
        INSERT INTO transcript_segments_fts(rowid, transcript_text)
        VALUES (new.rowid, new.transcript_text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS transcript_segments_fts_delete
      AFTER DELETE ON transcript_segments BEGIN
        INSERT INTO transcript_segments_fts(transcript_segments_fts, rowid, transcript_text)
        VALUES ('delete', old.rowid, old.transcript_text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS transcript_segments_fts_update
      AFTER UPDATE OF transcript_text ON transcript_segments BEGIN
        INSERT INTO transcript_segments_fts(transcript_segments_fts, rowid, transcript_text)
        VALUES ('delete', old.rowid, old.transcript_text);
        INSERT INTO transcript_segments_fts(rowid, transcript_text)
        VALUES (new.rowid, new.transcript_text);
      END
    ''');

    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS recording_titles_fts
      USING fts5(title, content='recordings', content_rowid='rowid')
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS recording_titles_fts_insert
      AFTER INSERT ON recordings BEGIN
        INSERT INTO recording_titles_fts(rowid, title)
        VALUES (new.rowid, new.title);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS recording_titles_fts_delete
      AFTER DELETE ON recordings BEGIN
        INSERT INTO recording_titles_fts(recording_titles_fts, rowid, title)
        VALUES ('delete', old.rowid, old.title);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS recording_titles_fts_update
      AFTER UPDATE OF title ON recordings BEGIN
        INSERT INTO recording_titles_fts(recording_titles_fts, rowid, title)
        VALUES ('delete', old.rowid, old.title);
        INSERT INTO recording_titles_fts(rowid, title)
        VALUES (new.rowid, new.title);
      END
    ''');
  }
}
