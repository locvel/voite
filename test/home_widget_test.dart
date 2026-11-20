import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicerecorder/domain/models/recording_details.dart';
import 'package:voicerecorder/features/home/home_data.dart';
import 'package:voicerecorder/features/home/home_screen.dart';

RecordingSummary _summary({String id = 'r1', String title = 'Voice note'}) =>
    RecordingSummary(
      id: id,
      title: title,
      audioPath: '/tmp/$id.wav',
      durationMillis: 61000,
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      transcriptionStatus: 'complete',
      transcriptPreview: 'A short thought saved to the diary.',
      transcriptSegmentCount: 1,
      isTrashed: false,
      isFavorite: false,
    );

Future<void> _pumpHome(
  WidgetTester tester, {
  List<RecordingSummary> recordings = const [],
}) async {
  await tester.binding.setSurfaceSize(const Size(600, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeRecordingsProvider.overrideWith((ref) => Stream.value(recordings)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('HomeScreen builds within ProviderScope', (tester) async {
    await _pumpHome(tester);

    expect(find.byType(Scaffold), findsOne);
    expect(find.text('Voite'), findsOne);
  });

  testWidgets('HomeScreen shows TODAY text', (tester) async {
    await _pumpHome(tester);

    expect(find.text('TODAY'), findsOne);
  });

  testWidgets('HomeScreen empty state renders without crashing', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.byType(Scaffold), findsOne);
    expect(find.textContaining('Nothing yet today'), findsOne);
  });

  testWidgets('HomeScreen shows library navigation button', (tester) async {
    await _pumpHome(tester);

    expect(find.text('See all'), findsOne);
  });

  testWidgets('HomeScreen renders recent recordings', (tester) async {
    await _pumpHome(tester, recordings: [_summary(title: 'Morning idea')]);

    expect(find.text('Morning idea'), findsOne);
  });
}
