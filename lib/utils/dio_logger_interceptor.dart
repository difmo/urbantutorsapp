import 'dart:convert';
import 'package:dio/dio.dart';

/// ANSI escape codes for coloring terminal output.
class _AnsiColor {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[91m';
  static const String green = '\x1B[92m';
  static const String yellow = '\x1B[93m';
  static const String cyan = '\x1B[96m';
}

/// Custom Dio logging interceptor that logs beautiful, color-coded
/// request, response, and error information directly to the terminal.
/// - 🚀 Requests: Bright Cyan
/// - ✅ 2xx Success: Bright Green
/// - ⚠️ 4xx Warnings: Bright Yellow
/// - ❌ 5xx & Errors: Bright Red
class DioLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['dio_logger_start_time'] =
        DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer();
    buffer.writeln(
        '╔════════════════════════════ [DIO REQUEST] ════════════════════════════');
    buffer.writeln('🚀 METHOD : ${options.method.toUpperCase()}');
    buffer.writeln('🌐 URL    : ${options.uri}');

    if (options.headers.isNotEmpty) {
      buffer.writeln('📋 HEADERS:');
      options.headers.forEach((key, value) {
        buffer.writeln('   • $key: $value');
      });
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('🔍 QUERY PARAMS:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('   • $key: $value');
      });
    }

    if (options.data != null) {
      buffer.writeln('📦 REQUEST BODY:');
      buffer.writeln(_formatRequestBody(options.data));
    }

    buffer.writeln(
        '╚══════════════════════════════════════════════════════════════════════');
    _printLog(buffer.toString(), color: _AnsiColor.cyan);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime =
        response.requestOptions.extra['dio_logger_start_time'] as int?;
    final duration = startTime != null
        ? ' [${DateTime.now().millisecondsSinceEpoch - startTime} ms]'
        : '';
    final statusCode = response.statusCode ?? 0;
    final isHttpError = statusCode < 200 || statusCode >= 400;
    final isBodyError =
        (response.data is Map && response.data['success'] == false);
    final isError = isHttpError || isBodyError;

    // Red for ALL errors (HTTP >= 400 or success: false), Green for success
    final logColor = isError ? _AnsiColor.red : _AnsiColor.green;
    final icon = isError ? '❌' : '✅';
    final tag = isError ? 'DIO ERROR' : 'DIO RESPONSE';

    final buffer = StringBuffer();
    buffer.writeln(
        '╔════════════════════════════ [$tag] ════════════════════════════');
    buffer.writeln(
        '$icon STATUS  : $statusCode ${response.statusMessage ?? ""}$duration');
    buffer.writeln('🚀 METHOD  : ${response.requestOptions.method.toUpperCase()}');
    buffer.writeln('🌐 URL     : ${response.requestOptions.uri}');
    buffer.writeln('📦 RESPONSE BODY:');
    buffer.writeln(_formatResponseBody(response.data));
    buffer.writeln(
        '╚══════════════════════════════════════════════════════════════════════');
    _printLog(buffer.toString(), color: logColor);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime =
        err.requestOptions.extra['dio_logger_start_time'] as int?;
    final duration = startTime != null
        ? ' [${DateTime.now().millisecondsSinceEpoch - startTime} ms]'
        : '';

    final buffer = StringBuffer();
    buffer.writeln(
        '╔═════════════════════════════ [DIO ERROR] ═════════════════════════════');
    buffer.writeln(
        '❌ STATUS  : ${err.response?.statusCode ?? "NO STATUS"}$duration');
    buffer.writeln('🚀 METHOD  : ${err.requestOptions.method.toUpperCase()}');
    buffer.writeln('🌐 URL     : ${err.requestOptions.uri}');
    buffer.writeln('⚠️ TYPE    : ${err.type}');
    buffer.writeln('💬 MESSAGE : ${err.message}');

    if (err.response?.data != null) {
      buffer.writeln('📦 ERROR BODY:');
      buffer.writeln(_formatResponseBody(err.response?.data));
    }

    buffer.writeln(
        '╚══════════════════════════════════════════════════════════════════════');
    _printLog(buffer.toString(), color: _AnsiColor.red);

    super.onError(err, handler);
  }

  String _formatRequestBody(dynamic data) {
    if (data == null) return '   (null)';
    if (data is FormData) {
      final lines = <String>[];
      if (data.fields.isNotEmpty) {
        lines.add('   [Fields]');
        for (final field in data.fields) {
          lines.add('   • ${field.key}: ${field.value}');
        }
      }
      if (data.files.isNotEmpty) {
        lines.add('   [Files]');
        for (final file in data.files) {
          lines.add(
              '   • ${file.key}: [File: ${file.value.filename}, size: ${file.value.length} bytes]');
        }
      }
      return lines.isEmpty ? '   (empty FormData)' : lines.join('\n');
    }
    return _formatJsonOrString(data);
  }

  String _formatResponseBody(dynamic data) {
    if (data == null) return '   (null / empty)';
    return _formatJsonOrString(data);
  }

  String _formatJsonOrString(dynamic data) {
    if (data is Map || data is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      } catch (_) {
        return data;
      }
    }
    return data.toString();
  }

  void _printLog(String text, {String color = ''}) {
    const int chunkSize = 900;
    final lines = text.split('\n');
    for (final line in lines) {
      final coloredLine =
          color.isNotEmpty ? '$color$line${_AnsiColor.reset}' : line;
      if (coloredLine.length <= chunkSize) {
        print(coloredLine);
      } else {
        for (int i = 0; i < coloredLine.length; i += chunkSize) {
          final end = (i + chunkSize < coloredLine.length)
              ? i + chunkSize
              : coloredLine.length;
          print(coloredLine.substring(i, end));
        }
      }
    }
  }
}
