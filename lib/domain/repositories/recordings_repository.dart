import '../models/transcript_segment.dart';
import '../models/recording_details.dart';

abstract interface class RecordingsRepository {
  Future<void> beginRecording({
    required String id,
    required String audioPath,
    String label = 'Voice note',
    String? prompt,
  });

  Future<void> saveRecording({
    required String id,
    required String audioPath,
    required int durationMillis,
    required List<TranscriptSegment> transcript,
    required bool transcriptionQueued,
    bool transcriptionFailed = false,
    String label = 'Voice note',
    String? prompt,
  });

  Future<PendingRecording?> nextQueuedRecording({String? recordingId});

  Future<void> saveTranscription({
    required String id,
    required List<TranscriptSegment> transcript,
  });

  Future<void> deleteRecording(String id);
  Future<void> moveToTrash(String id);
  Future<void> restoreRecording(String id);
  Future<void> emptyTrash();
  Future<void> renameRecording(String id, String title);
  Future<String?> recordingTitle(String id);
  Future<void> setRecordingLabel(String id, String label);
  Future<void> setFavorite(String id, bool isFavorite);
  Future<void> saveDiaryEntry({
    required String id,
    required String title,
    required String transcript,
  });
  Future<void> deleteDiaryEntry(String id);
  Future<void> deleteAllData();
  Stream<List<RecordingSummary>> watchLibrary({
    String query = '',
    bool showTrash = false,
    bool favoritesOnly = false,
    String? label,
  });
  Future<RecordingDetails?> getRecordingDetails(String id);
  Future<void> purgeExpiredTrash({DateTime? now});
}

class PendingRecording {
  const PendingRecording({required this.id, required this.audioPath});

  final String id;
  final String audioPath;
}

abstract interface class SettingsRepository {
  Future<bool> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
}
