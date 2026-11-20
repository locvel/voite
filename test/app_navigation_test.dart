import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voite/core/widgets/app_navigation.dart';

Future<void> _pumpNav(WidgetTester tester, int selectedIndex) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppNavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Navigation bar shows all 5 tabs', (tester) async {
    await _pumpNav(tester, 0);

    expect(find.text('Home'), findsOne);
    expect(find.text('Library'), findsOne);
    expect(find.text('Record'), findsOne);
    expect(find.text('Prompt'), findsOne);
    expect(find.text('Settings'), findsOne);
  });

  testWidgets('Record tab is always visible', (tester) async {
    // Test on each tab
    for (var i = 0; i < 5; i++) {
      await _pumpNav(tester, i);
      expect(
        find.text('Record'),
        findsOne,
        reason: 'Record tab should be visible on tab $i',
      );
    }
  });
}
