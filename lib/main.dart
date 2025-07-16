import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/AuthController.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Correctly register ApiService (no async/await needed unless init method exists)
  Get.put(ApiService());

  // Register AuthController after ApiService
  Get.put(AuthController());

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
