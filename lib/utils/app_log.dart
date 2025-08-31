import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Always-visible logs (debug/profile/release, mobile/web/desktop).
class AppLog {
  static void i(String msg, {String name = 'UT'}) {
    // devtools timeline + IDE debug console (debug/profile)
    if (!kReleaseMode) dev.log(msg, name: name);
    // device/web console everywhere
    debugPrint('[$name] $msg');
  }

  static void e(String msg, {String name = 'UT', Object? error, StackTrace? st}) {
    if (!kReleaseMode) dev.log(msg, name: name, error: error, stackTrace: st, level: 1000);
    debugPrint('[$name][ERROR] $msg ${error ?? ''}');
    if (st != null && !kReleaseMode) debugPrint(st.toString());
  }
}
