import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicerecorder/core/widgets/responsive_layout.dart';

void main() {
  group('ResponsiveBreakpoints', () {
    test('defines correct breakpoint values', () {
      expect(ResponsiveBreakpoints.medium, 600);
      expect(ResponsiveBreakpoints.expanded, 840);
    });
  });

  group('Responsive viewport tests', () {
    testWidgets('handles phone viewport (390x844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('ScreenSize: ${context.screenSize}'),
                  Text('IsTablet: ${context.isTablet}'),
                  Text('Columns: ${context.gridColumnCount}'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('ScreenSize: ScreenSize.compact'), findsOneWidget);
      expect(find.text('IsTablet: false'), findsOneWidget);
      expect(find.text('Columns: 1'), findsOneWidget);
    });

    testWidgets('handles iPad Portrait viewport (1024x1366)', (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('ScreenSize: ${context.screenSize}'),
                  Text('IsTablet: ${context.isTablet}'),
                  Text('Columns: ${context.gridColumnCount}'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('ScreenSize: ScreenSize.expanded'), findsOneWidget);
      expect(find.text('IsTablet: true'), findsOneWidget);
      expect(find.text('Columns: 3'), findsOneWidget);
    });

    testWidgets('handles iPad Landscape viewport (1366x1024)', (tester) async {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('ScreenSize: ${context.screenSize}'),
                  Text('IsTablet: ${context.isTablet}'),
                  Text('Columns: ${context.gridColumnCount}'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('ScreenSize: ScreenSize.expanded'), findsOneWidget);
      expect(find.text('IsTablet: true'), findsOneWidget);
      expect(find.text('Columns: 3'), findsOneWidget);
    });
  });

  group('ResponsiveLayout widget', () {
    testWidgets('shows compact layout on small screens', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            compact: Text('Compact'),
            medium: Text('Medium'),
            expanded: Text('Expanded'),
          ),
        ),
      );

      expect(find.text('Compact'), findsOneWidget);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Expanded'), findsNothing);
    });

    testWidgets('shows expanded layout on iPads', (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            compact: Text('Compact'),
            medium: Text('Medium'),
            expanded: Text('Expanded'),
          ),
        ),
      );

      expect(find.text('Compact'), findsNothing);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Expanded'), findsOneWidget);
    });

    testWidgets('shows no overflow with 2x text scale on tablets', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final columns = context.gridColumnCount;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 3.2,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Recording $index',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
