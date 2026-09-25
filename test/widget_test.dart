import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/widgets/CustomStudentNavBar.dart';
import 'package:urbantutorsapp/widgets/CustomTeacherNavBar.dart';

void main() {
  testWidgets('WelcomeScreen shows the three role buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Urban Tutors.'), findsOneWidget);
    expect(find.text('STUDENT / PARENT'), findsOneWidget);
    expect(find.text('PRIVATE TUTOR'), findsOneWidget);
    expect(find.text('TUTORS BUREAU'), findsOneWidget);
    expect(find.byType(FaIcon), findsNWidgets(3));
  });

  testWidgets('CustomStudentNavBar renders items and reports taps',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: CustomStudentNavBar(
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
      ),
    ));

    for (final label in ['Home', 'Chat', 'Upgrade', 'History', 'Support']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(FaIcon), findsNWidgets(5));

    await tester.tap(find.text('Upgrade'));
    expect(tapped, 2);
  });

  testWidgets('CustomTeacherNavBar renders items and reports taps',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: CustomTeacherNavBar(
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
      ),
    ));

    for (final label in ['Home', 'Notes', 'PYQs', 'Courses', 'Chats', 'Support']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(FaIcon), findsNWidgets(6));

    await tester.tap(find.text('Support'));
    expect(tapped, 5);
  });
}
