import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Get.snackbar renders (needs get >= 4.7.3 on Flutter 3.38+)', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: Text('x'))));
    Get.snackbar('Title', 'Hello probe');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Hello probe'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
