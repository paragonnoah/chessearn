import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessearn_new/screens/puzzle_screen.dart';
import 'package:chessearn_new/screens/game_board.dart'; // <-- Add this import

void main() {
  testWidgets('PuzzleScreen displays header and start button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleScreen(userId: 'user123'),
      ),
    );

    expect(find.text('Puzzle Odyssey'), findsOneWidget);
    expect(find.text('Start Puzzle'), findsOneWidget);
  });

  testWidgets('Tapping Start Puzzle shows the GameBoard', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleScreen(userId: 'user123'),
      ),
    );

    await tester.tap(find.text('Start Puzzle'));
    await tester.pump();

    expect(find.byType(GameBoard), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Enter Move (e.g., Nf3)'), findsOneWidget);
  });

  testWidgets('Submitting invalid move shows snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleScreen(userId: 'user123'),
      ),
    );

    await tester.tap(find.text('Start Puzzle'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(); // for snackbar to show

    expect(find.text('Invalid move or format.'), findsOneWidget);
  });
}