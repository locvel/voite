import 'dart:io';

import 'package:drift/drift.dart';

import '../../domain/models/transcript_segment.dart';
import '../../domain/models/recording_details.dart';
import '../../domain/repositories/recordings_repository.dart';
import '../database/voice_database.dart';

class LocalRecordingsRepository implements RecordingsRepository {
  LocalRecordingsRepository(this._database);

  final VoiceDatabase _database;

  @override
  Future<void> beginRecording({
    required String id,
    required String audioPath,
    String label = 'Voice note',
    String? prompt,
  }) async {
    final createdAt = DateTime.now();
    await _database
        .into(_database.recordings)
        .insert(
          RecordingsCompanion.insert(
            id: id,
            title: Value(_defaultRecordingTitle(createdAt, prefix: label)),
            label: Value(label),
            prompt: Value(prompt),
            audioPath: audioPath,
            createdAtMillis: createdAt.millisecondsSinceEpoch,
            transcriptionStatus: const Value('recording'),
          ),
        );
  }

  @override
  Future<void> saveRecording({
    required String id,
    required String audioPath,
    required int durationMillis,
    required List<TranscriptSegment> transcript,
    required bool transcriptionQueued,
    bool transcriptionFailed = false,
    String label = 'Voice note',
    String? prompt,
  }) async {
    await _database.transaction(() async {
      final row = await (_database.select(
        _database.recordings,
      )..where((recording) => recording.id.equals(id))).getSingleOrNull();
      final status = transcriptionFailed
          ? 'failed'
          : transcriptionQueued
          ? 'queued'
          : 'complete';
      final createdAt = DateTime.now();
      if (row == null) {
        await _database
            .into(_database.recordings)
            .insert(
              RecordingsCompanion.insert(
                id: id,
                title: Value(_defaultRecordingTitle(createdAt, prefix: label)),
                label: Value(label),
                prompt: Value(prompt),
                audioPath: audioPath,
                durationMillis: Value(durationMillis),
                createdAtMillis: createdAt.millisecondsSinceEpoch,
                transcriptionStatus: Value(status),
              ),
            );
      } else {
        await (_database.update(
          _database.recordings,
        )..where((recording) => recording.id.equals(id))).write(
          RecordingsCompanion(
            audioPath: Value(audioPath),
            durationMillis: Value(durationMillis),
            transcriptionStatus: Value(status),
          ),
        );
      }
      await (_database.delete(
        _database.transcriptSegments,
      )..where((segment) => segment.recordingId.equals(id))).go();
      for (final segment in transcript) {
        await _database
            .into(_database.transcriptSegments)
            .insert(
              TranscriptSegmentsCompanion.insert(
                recordingId: id,
                startMillis: segment.startMillis,
                endMillis: segment.endMillis,
                transcriptText: segment.text,
              ),
            );
      }
    });
  }

  @override
  Future<PendingRecording?> nextQueuedRecording({String? recordingId}) async {
    final query = _database.select(_database.recordings)
      ..where(
        (recording) => recording.transcriptionStatus.isIn(['queued', 'failed']),
      )
      ..where((recording) => recording.trashedAtMillis.isNull());
    if (recordingId != null) {
      query.where((recording) => recording.id.equals(recordingId));
    }
    final row =
        await (query
              ..orderBy([
                (recording) => OrderingTerm.asc(recording.createdAtMillis),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null
        ? null
        : PendingRecording(id: row.id, audioPath: row.audioPath);
  }

  @override
  Stream<List<RecordingSummary>> watchLibrary({
    String query = '',
    bool showTrash = false,
    bool favoritesOnly = false,
    String? label,
  }) {
    final normalized = query.trim().toLowerCase();
    final parameters = <Variable<Object>>[];
    final searchStartExpression = normalized.isEmpty
        ? 'NULL'
        : '''(
          SELECT matched.start_millis FROM transcript_segments matched
          WHERE matched.recording_id = r.id
            AND LOWER(matched.transcript_text) LIKE ? ESCAPE '\\'
          ORDER BY matched.start_millis LIMIT 1
        )''';
    if (normalized.isNotEmpty) {
      parameters.add(Variable<String>('%${_escapeLike(normalized)}%'));
    }
    final predicates = <String>[
      showTrash
          ? 'r.trashed_at_millis IS NOT NULL'
          : 'r.trashed_at_millis IS NULL',
    ];
    if (favoritesOnly && !showTrash) predicates.add('r.is_favorite = 1');
    if (label != null && !showTrash) {
      predicates.add('r.label = ?');
      parameters.add(Variable<String>(label));
    }
    if (normalized.isNotEmpty) {
      final pattern = '%${_escapeLike(normalized)}%';
      predicates.add('''(
        LOWER(r.title) LIKE ? ESCAPE '\\'
        OR LOWER(r.label) LIKE ? ESCAPE '\\'
        OR EXISTS (
          SELECT 1 FROM transcript_segments s
          WHERE s.recording_id = r.id
            AND LOWER(s.transcript_text) LIKE ? ESCAPE '\\'
        )
      )''');
      parameters
        ..add(Variable<String>(pattern))
        ..add(Variable<String>(pattern))
        ..add(Variable<String>(pattern));
    }

    final selectQuery = _database.customSelect(
      '''
      SELECT r.*,
        $searchStartExpression AS search_match_start_millis,
        COALESCE((
          SELECT substr(group_concat(preview.transcript_text, ' '), 1, 220)
          FROM (
            SELECT transcript_text FROM transcript_segments
            WHERE recording_id = r.id ORDER BY start_millis LIMIT 4
          ) AS preview
        ), '') AS transcript_preview,
        (SELECT COUNT(*) FROM transcript_segments s WHERE s.recording_id = r.id)
          AS transcript_segment_count
      FROM recordings r
      WHERE ${predicates.join(' AND ')}
      ORDER BY r.created_at_millis DESC
      ''',
      variables: parameters,
      readsFrom: {_database.recordings, _database.transcriptSegments},
    );

    return selectQuery.watch().map(
      (rows) => rows
          .map(
            (row) => RecordingSummary(
              id: row.read<String>('id'),
              title: row.read<String>('title'),
              label: row.read<String>('label'),
              audioPath: row.read<String>('audio_path'),
              durationMillis: row.read<int>('duration_millis'),
              createdAtMillis: row.read<int>('created_at_millis'),
              transcriptionStatus: row.read<String>('transcription_status'),
              transcriptPreview: row.read<String>('transcript_preview'),
              transcriptSegmentCount: row.read<int>('transcript_segment_count'),
              isTrashed: row.read<int?>('trashed_at_millis') != null,
              isFavorite: row.read<int>('is_favorite') != 0,
              prompt: row.read<String?>('prompt'),
              diaryEdited: row.read<int>('diary_edited') != 0,
              searchMatchStartMillis: row.read<int?>(
                'search_match_start_millis',
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<RecordingDetails?> getRecordingDetails(String id) async {
    final row = await (_database.select(
      _database.recordings,
    )..where((recording) => recording.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final segments =
        await (_database.select(_database.transcriptSegments)
              ..where((segment) => segment.recordingId.equals(id))
              ..orderBy([(segment) => OrderingTerm.asc(segment.startMillis)]))
            .get();
    return RecordingDetails(
      recording: RecordingSummary(
        id: row.id,
        title: row.title,
        label: row.label,
        audioPath: row.audioPath,
        durationMillis: row.durationMillis,
        createdAtMillis: row.createdAtMillis,
        transcriptionStatus: row.transcriptionStatus,
        transcriptPreview: segments
            .take(4)
            .map((segment) => segment.transcriptText)
            .join(' '),
        transcriptSegmentCount: segments.length,
        isTrashed: row.trashedAtMillis != null,
        isFavorite: row.isFavorite,
        prompt: row.prompt,
        diaryEdited: row.diaryEdited,
      ),
      transcript: List.unmodifiable(
        segments.map(
          (segment) => TranscriptSegment(
            text: segment.transcriptText,
            startMillis: segment.startMillis,
            endMillis: segment.endMillis,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> renameRecording(String id, String title) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw ArgumentError.value(title, 'title');
    await (_database.update(_database.recordings)
          ..where((recording) => recording.id.equals(id)))
        .write(RecordingsCompanion(title: Value(cleanTitle)));
  }

  @override
  Future<String?> recordingTitle(String id) async {
    final row = await (_database.select(
      _database.recordings,
    )..where((recording) => recording.id.equals(id))).getSingleOrNull();
    return row?.title;
  }

  @override
  Future<void> setRecordingLabel(String id, String label) async {
    final cleanLabel = label.trim();
    if (cleanLabel.isEmpty) throw ArgumentError.value(label, 'label');
    await (_database.update(_database.recordings)
          ..where((recording) => recording.id.equals(id)))
        .write(RecordingsCompanion(label: Value(cleanLabel)));
  }

  @override
  Future<void> setFavorite(String id, bool isFavorite) async {
    await (_database.update(_database.recordings)
          ..where((recording) => recording.id.equals(id)))
        .write(RecordingsCompanion(isFavorite: Value(isFavorite)));
  }

  @override
  Future<void> saveDiaryEntry({
    required String id,
    required String title,
    required String transcript,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw ArgumentError.value(title, 'title');
    final cleanText = transcript.trim();
    await _database.transaction(() async {
      await (_database.update(
        _database.recordings,
      )..where((r) => r.id.equals(id))).write(
        RecordingsCompanion(
          title: Value(cleanTitle),
          diaryEdited: const Value(true),
        ),
      );
      await (_database.delete(
        _database.transcriptSegments,
      )..where((s) => s.recordingId.equals(id))).go();
      if (cleanText.isNotEmpty) {
        await _database
            .into(_database.transcriptSegments)
            .insert(
              TranscriptSegmentsCompanion.insert(
                recordingId: id,
                startMillis: 0,
                endMillis: 0,
                transcriptText: cleanText,
              ),
            );
        await (_database.update(
          _database.recordings,
        )..where((r) => r.id.equals(id))).write(
          const RecordingsCompanion(transcriptionStatus: Value('complete')),
        );
      } else {
        await (_database.update(
          _database.recordings,
        )..where((r) => r.id.equals(id))).write(
          const RecordingsCompanion(transcriptionStatus: Value('audio_only')),
        );
      }
    });
  }

  @override
  Future<void> deleteDiaryEntry(String id) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.transcriptSegments,
      )..where((s) => s.recordingId.equals(id))).go();
      await (_database.update(
        _database.recordings,
      )..where((r) => r.id.equals(id))).write(
        const RecordingsCompanion(transcriptionStatus: Value('audio_only')),
      );
    });
  }

  @override
  Future<void> deleteAllData() async {
    final rows = await _database.select(_database.recordings).get();
    for (final row in rows) {
      final audio = File(row.audioPath);
      if (await audio.exists()) await audio.delete();
    }
    await _database.transaction(() async {
      await _database.delete(_database.recordings).go();
      await _database.delete(_database.transcriptSegments).go();
      await _database.delete(_database.exports).go();
    });
  }

  @override
  Future<void> moveToTrash(String id) async {
    await (_database.update(
      _database.recordings,
    )..where((recording) => recording.id.equals(id))).write(
      RecordingsCompanion(
        trashedAtMillis: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<void> restoreRecording(String id) async {
    await (_database.update(_database.recordings)
          ..where((recording) => recording.id.equals(id)))
        .write(const RecordingsCompanion(trashedAtMillis: Value(null)));
  }

  @override
  Future<void> emptyTrash() async {
    final rows = await (_database.select(
      _database.recordings,
    )..where((recording) => recording.trashedAtMillis.isNotNull())).get();
    for (final row in rows) {
      await deleteRecording(row.id);
    }
  }

  @override
  Future<void> saveTranscription({
    required String id,
    required List<TranscriptSegment> transcript,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.transcriptSegments,
      )..where((segment) => segment.recordingId.equals(id))).go();
      for (final segment in transcript) {
        await _database
            .into(_database.transcriptSegments)
            .insert(
              TranscriptSegmentsCompanion.insert(
                recordingId: id,
                startMillis: segment.startMillis,
                endMillis: segment.endMillis,
                transcriptText: segment.text,
              ),
            );
      }
      await (_database.update(
        _database.recordings,
      )..where((recording) => recording.id.equals(id))).write(
        const RecordingsCompanion(transcriptionStatus: Value('complete')),
      );
    });
  }

  @override
  Future<void> deleteRecording(String id) async {
    final row = await (_database.select(
      _database.recordings,
    )..where((recording) => recording.id.equals(id))).getSingleOrNull();
    if (row == null) return;

    final audio = File(row.audioPath);
    File? stagedFile;
    if (await audio.exists()) {
      stagedFile = File('${row.audioPath}.delete-pending');
      if (await stagedFile.exists()) await stagedFile.delete();
      await audio.rename(stagedFile.path);
    }

    try {
      await _database.transaction(() async {
        await (_database.delete(
          _database.recordings,
        )..where((recording) => recording.id.equals(id))).go();
      });
    } catch (_) {
      if (stagedFile != null && await stagedFile.exists()) {
        await stagedFile.rename(audio.path);
      }
      rethrow;
    }

    if (stagedFile != null && await stagedFile.exists()) {
      await stagedFile.delete();
    }
  }

  @override
  Future<void> purgeExpiredTrash({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now())
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    final expired =
        await (_database.select(_database.recordings)..where(
              (recording) =>
                  recording.trashedAtMillis.isSmallerOrEqualValue(cutoff),
            ))
            .get();
    for (final recording in expired) {
      await deleteRecording(recording.id);
    }
  }
}

String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

String _defaultRecordingTitle(DateTime value, {String prefix = 'Voice note'}) =>
    '$prefix · ${_shortMonth(value.month)} ${value.day}';

String _shortMonth(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._database);

  final VoiceDatabase _database;

  @override
  Future<bool> getBool(String key) async {
    final row = await (_database.select(
      _database.settings,
    )..where((setting) => setting.settingKey.equals(key))).getSingleOrNull();
    return row?.value == 'true';
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(settingKey: key, value: value.toString()),
        );
  }

  @override
  Future<String?> getString(String key) async {
    final row = await (_database.select(
      _database.settings,
    )..where((setting) => setting.settingKey.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(settingKey: key, value: value),
        );
  }

  @override
  Future<int?> getInt(String key) async {
    final row = await (_database.select(
      _database.settings,
    )..where((setting) => setting.settingKey.equals(key))).getSingleOrNull();
    return row?.value != null ? int.tryParse(row!.value) : null;
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(settingKey: key, value: value.toString()),
        );
  }
}
