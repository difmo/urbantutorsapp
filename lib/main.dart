import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/AuthController.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController(),permanent: true);    // ✅ 

  runApp(const UrbanTutorsProApp());
}

class UrbanTutorsProApp extends StatelessWidget {
  const UrbanTutorsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // ✅ Use GetMaterialApp for GetX navigation/dialogs
      debugShowCheckedModeBanner: false,
      title: 'Urban Tutors Pro',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
    );
  }
}
