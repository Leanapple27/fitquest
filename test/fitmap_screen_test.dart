import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/app_state.dart';
import 'package:fitquest/screens/fitmap_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createFitMapTestApp({required AppState appState}) {
    return MaterialApp(
      home: FitMapScreen(appState: appState),
    );
  }

  testWidgets('FitMap renders all default activities and filter chips', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(createFitMapTestApp(appState: appState));
    await tester.pumpAndSettle();

    // Verify title and filters
    expect(find.text('FitMap'), findsOneWidget);
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('RUN'), findsOneWidget);
    expect(find.text('SPORT'), findsOneWidget);
    expect(find.text('GYM'), findsOneWidget);

    // Verify search field exists
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search activity areas or sports...'), findsOneWidget);

    // Verify default nearby activities title
    expect(find.text('Nearby activities'), findsOneWidget);
  });

  testWidgets('FitMap FREE and SPORT filters work properly without blank screen', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(createFitMapTestApp(appState: appState));
    await tester.pumpAndSettle();

    // Tap FREE filter (the first instance is the filter chip)
    await tester.tap(find.text('FREE').first);
    await tester.pumpAndSettle();

    expect(find.text('FREE activities'), findsOneWidget);
    expect(find.text('Running Track'), findsWidgets);

    // Tap SPORT filter
    await tester.tap(find.text('SPORT').first);
    await tester.pumpAndSettle();

    expect(find.text('SPORT activities'), findsOneWidget);
    expect(find.text('Basketball Court'), findsWidgets);

    // Tap GYM filter
    await tester.tap(find.text('GYM'));
    await tester.pumpAndSettle();

    expect(find.text('GYM activities'), findsOneWidget);
    expect(find.text('Fitness Gym'), findsWidgets);

    // Tap RUN filter
    await tester.tap(find.text('RUN'));
    await tester.pumpAndSettle();

    expect(find.text('RUN activities'), findsOneWidget);
    expect(find.text('Running Track'), findsWidgets);
  });

  testWidgets('FitMap live search filters items and shows empty state on no match', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(createFitMapTestApp(appState: appState));
    await tester.pumpAndSettle();

    // Enter search text "Track"
    await tester.enterText(find.byType(TextField), 'Track');
    await tester.pumpAndSettle();

    expect(find.text('Running Track'), findsWidgets);

    // Enter non-matching search text
    await tester.enterText(find.byType(TextField), 'NonExistentPlace');
    await tester.pumpAndSettle();

    expect(find.text('No activities found'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // Tap Reset
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Nearby activities'), findsOneWidget);
  });

  testWidgets('FitMap activity selection and XP completion works', (tester) async {
    final appState = AppState();
    final initialXp = appState.xp;

    await tester.pumpWidget(createFitMapTestApp(appState: appState));
    await tester.pumpAndSettle();

    // Tap on Running Track card
    await tester.tap(find.text('Running Track').first);
    await tester.pumpAndSettle();

    expect(find.text('START ACTIVITY'), findsOneWidget);

    // Tap Start Activity
    await tester.tap(find.text('START ACTIVITY'));
    await tester.pump();
    ScaffoldMessenger.of(tester.element(find.byType(FitMapScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    expect(find.text('COMPLETE ACTIVITY'), findsOneWidget);

    // Tap Complete Activity
    await tester.tap(find.text('COMPLETE ACTIVITY'));
    await tester.pump();
    ScaffoldMessenger.of(tester.element(find.byType(FitMapScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    expect(appState.xp, greaterThan(initialXp));
  });
}
