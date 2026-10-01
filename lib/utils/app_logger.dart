import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Central application logger providing color-coded, formatted logging
/// across the entire app using the `logger` package.
class AppLogger {
  static const String _ansiReset = '\x1B[0m';
  static const String _ansiBoldRed = '\x1B[1;31m';

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  /// Prints error in bright red directly to the console/terminal
  static void printRed(String message) {
    const int chunkSize = 900;
    final lines = message.split('\n');
    for (final line in lines) {
      if (line.length <= chunkSize) {
        print('$_ansiBoldRed$line$_ansiReset');
      } else {
        for (int i = 0; i < line.length; i += chunkSize) {
          final end = (i + chunkSize < line.length) ? i + chunkSize : line.length;
          print('$_ansiBoldRed${line.substring(i, end)}$_ansiReset');
        }
      }
    }
  }

  /// Logs API error with red borders and details directly to terminal
  static void apiError(
    dynamic message, {
    String? method,
    String? url,
    int? statusCode,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
        '╔═════════════════════════════ [API ERROR] ═════════════════════════════');
    if (method != null) buffer.writeln('🚀 METHOD  : ${method.toUpperCase()}');
    if (url != null) buffer.writeln('🌐 URL     : $url');
    if (statusCode != null) buffer.writeln('❌ STATUS  : $statusCode');
    buffer.writeln('💬 MESSAGE : $message');
    if (error != null) buffer.writeln('📦 DETAILS : $error');
    buffer.writeln(
        '╚══════════════════════════════════════════════════════════════════════');

    printRed(buffer.toString());

    if (stackTrace != null && kDebugMode) {
      printRed(stackTrace.toString());
    }
  }

  /// Debug message (grey/blue)
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Informational message (cyan)
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Warning message (yellow)
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error message (red)
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    printRed('❌ [ERROR] $message${error != null ? " ($error)" : ""}');
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Trace message
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.t(message, error: error, stackTrace: stackTrace);
  }
}
