import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voite/domain/models/recording_details.dart';
import 'package:voite/features/diary/diary_screen.dart';
import 'package:voite/features/home/home_data.dart';

RecordingSummary _summary({
  String id = 'r1',
  String title = 'Morning thought',
  String status = 'complete',
  String preview = 'I noticed the light in the kitchen.',
}) => RecordingSummary(
  id: id,
  title: title,
  audioPath: '/tmp/$id.wav',
  durationMillis: 45000,
  createdAtMillis: DateTime.now().millisecondsSinceEpoch,
  transcriptionStatus: status,
  transcriptPreview: preview,
  transcriptSegmentCount: 1,
  isTrashed: false,
  isFavorite: false,
);

Future<void> _pumpDiary(
  WidgetTester tester, {
  List<RecordingSummary> recordings = const [],
  String? initialRecordingId,
}) async {
  await tester.binding.setSurfaceSize(const Size(600, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeRecordingsProvider.overrideWith((ref) => Stream.value(recordings)),
      ],
      child: MaterialApp(
        home: DiaryScreen(initialRecordingId: initialRecordingId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('DiaryScreen shows an empty state without entries', (
    tester,
  ) async {
    await _pumpDiary(tester);

    expect(find.text('Your diary'), findsOne);
    expect(find.textContaining('Nothing here yet'), findsOne);
  });

  testWidgets('DiaryScreen lists entries grouped under Today', (tester) async {
    await _pumpDiary(tester, recordings: [_summary()]);

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Morning thought'), findsOne);
    expect(find.textContaining('light in the kitchen'), findsOne);
  });

  testWidgets('DiaryScreen marks the newest recording as New', (tester) async {
    await _pumpDiary(
      tester,
      recordings: [_summary()],
      initialRecordingId: 'r1',
    );

    expect(find.text('New'), findsOne);
  });

  testWidgets('DiaryScreen hides trashed recordings', (tester) async {
    final trashed = _summary(id: 'r2', title: 'Deleted note');
    final trashedRecording = RecordingSummary(
      id: trashed.id,
      title: trashed.title,
      audioPath: trashed.audioPath,
      durationMillis: trashed.durationMillis,
      createdAtMillis: trashed.createdAtMillis,
      transcriptionStatus: trashed.transcriptionStatus,
      transcriptPreview: trashed.transcriptPreview,
      transcriptSegmentCount: trashed.transcriptSegmentCount,
      isTrashed: true,
      isFavorite: false,
    );
    await _pumpDiary(tester, recordings: [trashedRecording]);

    expect(find.text('Deleted note'), findsNothing);
    expect(find.textContaining('Nothing here yet'), findsOne);
  });
}
