import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voite/data/database/voice_database.dart';
import 'package:voite/data/repositories/local_repositories.dart';
import 'package:voite/domain/models/transcript_segment.dart';

void main() {
  late VoiceDatabase database;
  late LocalRecordingsRepository repository;
  late Directory tempDirectory;

  setUp(() async {
    database = VoiceDatabase.forTesting(NativeDatabase.memory());
    repository = LocalRecordingsRepository(database);
    tempDirectory = await Directory.systemTemp.createTemp(
      'voice-recorder-test-',
    );
  });

  tearDown(() async {
    await database.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'deleting a recording removes its file, transcript and FTS row',
    () async {
      const id = 'recording-one';
      final audio = File('${tempDirectory.path}/recording.wav');
      await audio.writeAsBytes([1, 2, 3, 4]);
      await repository.beginRecording(id: id, audioPath: audio.path);
      await repository.saveRecording(
        id: id,
        audioPath: audio.path,
        durationMillis: 1000,
        transcriptionQueued: false,
        transcript: const [
          TranscriptSegment(
            text: 'unique lecture phrase',
            startMillis: 0,
            endMillis: 900,
          ),
        ],
      );

      final beforeDelete = await database
          .customSelect(
            "SELECT count(*) AS count FROM transcript_segments_fts "
            "WHERE transcript_segments_fts MATCH 'lecture'",
          )
          .getSingle();
      expect(beforeDelete.read<int>('count'), 1);

      await repository.deleteRecording(id);

      expect(await audio.exists(), isFalse);
      expect(
        await (database.select(
          database.recordings,
        )..where((row) => row.id.equals(id))).getSingleOrNull(),
        isNull,
      );
      expect(
        await (database.select(
          database.transcriptSegments,
        )..where((row) => row.recordingId.equals(id))).get(),
        isEmpty,
      );
      final afterDelete = await database
          .customSelect(
            "SELECT count(*) AS count FROM transcript_segments_fts "
            "WHERE transcript_segments_fts MATCH 'lecture'",
          )
          .getSingle();
      expect(afterDelete.read<int>('count'), 0);
    },
  );
}
