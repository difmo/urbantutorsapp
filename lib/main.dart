import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/utils/session.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print any runtime Flutter errors in bright red
  FlutterError.onError = (FlutterErrorDetails details) {
    print('\x1B[91m══════════════════ [FLUTTER ERROR] ══════════════════\x1B[0m');
    print('\x1B[91m${details.exceptionAsString()}\x1B[0m');
    print('\x1B[91m═════════════════════════════════════════════════════\x1B[0m');
    FlutterError.presentError(details);
  };

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('\x1B[91m[ENV ERROR] Failed to load .env: $e\x1B[0m');
  }
  Session.registerControllers();

  runApp(const UrbanTutorsProApp());
}

class UrbanTutorsProApp extends StatelessWidget {
  const UrbanTutorsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ✅ Use GetMaterialApp for GetX navigation/dialogs
      debugShowCheckedModeBanner: false,
      title: 'Urban Tutors Pro',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
    );
  }
}
