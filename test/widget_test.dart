import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/main.dart';

void main() {
  testWidgets('FitQuest app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const FitQuestApp());

    expect(find.text('FITQUEST'), findsOneWidget);
  });
}