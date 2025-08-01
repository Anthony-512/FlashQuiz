import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/app.dart';
import 'package:quiz_app/screens/home_screen.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const QuizApp());

    // Verify that the HomeScreen is loaded
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verify the app title is shown
    expect(find.text('Subjects'), findsOneWidget);
  });

  testWidgets('Can create new subject', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizApp());
    
    // Tap the '+' button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    
    // Verify the dialog appears
    expect(find.text('Create New Subject'), findsOneWidget);
    
    // Enter subject name
    await tester.enterText(find.byType(TextFormField), 'Math');
    await tester.pump();
    
    // Select a color (first color in the list)
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    
    // Tap the Create button
    await tester.tap(find.text('Create'));
    await tester.pump();
    
    // Verify the new subject appears
    expect(find.text('Math'), findsOneWidget);
  });
}