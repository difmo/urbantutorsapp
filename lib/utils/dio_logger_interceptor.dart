import 'dart:convert';
import 'package:dio/dio.dart';

/// ANSI escape codes for coloring terminal output.
class _AnsiColor {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[1;31m';   // Bold Red (Universal ANSI)
  static const String green = '\x1B[1;32m'; // Bold Green
  static const String cyan = '\x1B[1;36m';  // Bold Cyan
}

/// Custom Dio logging interceptor that logs beautiful, color-coded
/// request, response, and error information directly to the terminal.
/// - 🚀 Requests: Bright Cyan
/// - ✅ 2xx Success: Bright Green
/// - ⚠️ Warnings: Bright Yellow
/// - ❌ API Errors (HTTP >= 400, status/success=false, DioException): Bold Red
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
    final isError = _isErrorResponse(response);

    // Bold Red for ALL API errors (HTTP >= 400, success/status false, etc.)
    final logColor = isError ? _AnsiColor.red : _AnsiColor.green;
    final icon = isError ? '❌' : '✅';
    final tag = isError ? 'DIO API ERROR' : 'DIO RESPONSE';

    final buffer = StringBuffer();
    buffer.writeln(
        '╔════════════════════════════ [$tag] ════════════════════════════');
    buffer.writeln(
        '$icon STATUS  : $statusCode ${response.statusMessage ?? ""}$duration');
    buffer.writeln('🚀 METHOD  : ${response.requestOptions.method.toUpperCase()}');
    buffer.writeln('🌐 URL     : ${response.requestOptions.uri}');
    buffer.writeln(isError ? '📦 ERROR / RESPONSE BODY:' : '📦 RESPONSE BODY:');
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
        '╔═════════════════════════════ [DIO API ERROR] ═════════════════════════════');
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

  bool _isErrorResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 400) return true;

    final data = response.data;
    if (data is Map) {
      // 1. Check success flag
      final success = data['success'];
      if (success == false ||
          success == 0 ||
          success == 'false' ||
          success == '0') {
        return true;
      }

      // 2. Check status flag
      final status = data['status'];
      if (status == false ||
          status == 0 ||
          status == 'false' ||
          status == '0' ||
          status == 'error' ||
          status == 'failed' ||
          status == 'failure') {
        return true;
      }

      // 3. Check error
      if (data.containsKey('error') &&
          data['error'] != null &&
          data['error'] != false &&
          data['error'] != '') {
        return true;
      }

      // 4. Check errors list/map
      if (data.containsKey('errors') && data['errors'] != null) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) return true;
        if (errors is Map && errors.isNotEmpty) return true;
        if (errors is String && errors.trim().isNotEmpty) return true;
      }

      // 5. Check code inside response payload
      final code = data['code'];
      if (code is int && (code < 200 || code >= 400)) return true;
      if (code is String) {
        final parsed = int.tryParse(code);
        if (parsed != null && (parsed < 200 || parsed >= 400)) return true;
      }
    }
    return false;
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
      if (line.length <= chunkSize) {
        final colored =
            color.isNotEmpty ? '$color$line${_AnsiColor.reset}' : line;
        print(colored);
      } else {
        for (int i = 0; i < line.length; i += chunkSize) {
          final end = (i + chunkSize < line.length)
              ? i + chunkSize
              : line.length;
          final chunk = line.substring(i, end);
          final colored =
              color.isNotEmpty ? '$color$chunk${_AnsiColor.reset}' : chunk;
          print(colored);
        }
      }
    }
  }
}
