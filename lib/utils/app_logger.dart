import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Central application logger providing color-coded, formatted logging
/// across the entire app using the `logger` package.
class AppLogger {
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
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Trace message
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.t(message, error: error, stackTrace: stackTrace);
  }
}
