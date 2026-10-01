import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AppLog {
  static const String _ansiReset = '\x1B[0m';
  static const String _ansiBoldRed = '\x1B[1;31m';
  static const String _ansiBoldGreen = '\x1B[1;32m';
  static const String _ansiBoldCyan = '\x1B[1;36m';
  static const String _ansiBoldYellow = '\x1B[1;33m';

  static void i(String msg, {String name = 'UT'}) {
    if (!kReleaseMode) dev.log(msg, name: name);
    final lower = msg.toLowerCase();
    final isSuccess = lower.contains('success') || msg.contains('✅');
    final isWarning = lower.contains('warn') || msg.contains('⚠️');
    final isError = lower.contains('fail') || lower.contains('error') || msg.contains('❌');

    final color = isError
        ? _ansiBoldRed
        : (isSuccess
            ? _ansiBoldGreen
            : (isWarning ? _ansiBoldYellow : _ansiBoldCyan));

    print('$color[$name] $msg$_ansiReset');
  }

  static void s(String msg, {String name = 'UT'}) {
    if (!kReleaseMode) dev.log(msg, name: name);
    print('$_ansiBoldGreen[$name][SUCCESS] $msg$_ansiReset');
  }

  static void w(String msg, {String name = 'UT'}) {
    if (!kReleaseMode) dev.log(msg, name: name);
    print('$_ansiBoldYellow[$name][WARN] $msg$_ansiReset');
  }

  static void e(String msg,
      {String name = 'UT', Object? error, StackTrace? st}) {
    if (!kReleaseMode) {
      dev.log(msg, name: name, error: error, stackTrace: st, level: 1000);
    }
    final errStr = error != null ? ' $error' : '';
    print('$_ansiBoldRed[$name][ERROR] $msg$errStr$_ansiReset');
    if (st != null && !kReleaseMode) {
      print('$_ansiBoldRed$st$_ansiReset');
    }
  }
}
