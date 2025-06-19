import 'package:flutter/material.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UrbanTutorsProApp());
}

class UrbanTutorsProApp extends StatelessWidget {
  const UrbanTutorsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Tutors Pro',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
    );
  }
}
