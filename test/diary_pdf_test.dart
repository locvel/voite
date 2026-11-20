import 'package:flutter_test/flutter_test.dart';
import 'package:voicerecorder/domain/models/recording_details.dart';
import 'package:voicerecorder/domain/models/transcript_segment.dart';
import 'package:voicerecorder/features/diary/diary_pdf.dart';

RecordingDetails _entry({
  required String id,
  required String title,
  required DateTime createdAt,
  String preview = 'A short thought saved to the diary.',
  String? prompt,
}) {
  final recording = RecordingSummary(
    id: id,
    title: title,
    audioPath: '/tmp/$id.wav',
    durationMillis: 65000,
    createdAtMillis: createdAt.millisecondsSinceEpoch,
    transcriptionStatus: 'complete',
    transcriptPreview: preview,
    transcriptSegmentCount: 1,
    isTrashed: false,
    isFavorite: false,
    prompt: prompt,
  );
  return RecordingDetails(
    recording: recording,
    transcript: [
      TranscriptSegment(text: preview, startMillis: 0, endMillis: 1200),
      TranscriptSegment(
        text: 'This second segment is included in the full export.',
        startMillis: 1200,
        endMillis: 2600,
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildDiaryPdf produces a PDF with every entry', () async {
    final bytes = await buildDiaryPdf([
      _entry(
        id: 'a',
        title: 'Morning thought',
        createdAt: DateTime(2026, 11, 18, 9, 12),
        prompt: 'What did you notice today?',
      ),
      _entry(
        id: 'b',
        title: 'Evening walk',
        createdAt: DateTime(2026, 11, 17, 19, 40),
        preview: 'The air smelled like rain.',
      ),
    ], generatedAt: DateTime(2026, 11, 18, 12));

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('buildDiaryPdf handles an empty diary', () async {
    final bytes = await buildDiaryPdf(
      const [],
      generatedAt: DateTime(2026, 11, 18, 12),
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
