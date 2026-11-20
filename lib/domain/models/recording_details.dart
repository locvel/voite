import 'transcript_segment.dart';

class RecordingSummary {
  const RecordingSummary({
    required this.id,
    required this.title,
    this.label = 'Voice note',
    required this.audioPath,
    required this.durationMillis,
    required this.createdAtMillis,
    required this.transcriptionStatus,
    required this.transcriptPreview,
    required this.transcriptSegmentCount,
    required this.isTrashed,
    required this.isFavorite,
    this.prompt,
    this.diaryEdited = false,
    this.searchMatchStartMillis,
  });

  final String id;
  final String title;
  final String label;
  final String audioPath;
  final int durationMillis;
  final int createdAtMillis;
  final String transcriptionStatus;
  final String transcriptPreview;
  final int transcriptSegmentCount;
  final bool isTrashed;
  final bool isFavorite;
  final String? prompt;
  final bool diaryEdited;
  final int? searchMatchStartMillis;

  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtMillis);
}

class RecordingDetails {
  const RecordingDetails({required this.recording, required this.transcript});

  final RecordingSummary recording;
  final List<TranscriptSegment> transcript;
}
