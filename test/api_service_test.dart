import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

/// Replies to every request with a canned response (or error).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.status = 200, this.body = '', this.contentType, this.error});

  final int status;
  final String body;
  final String? contentType;
  final DioExceptionType? error;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    lastRequest = options;
    if (error != null) {
      throw DioException(requestOptions: options, type: error!);
    }
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: [contentType ?? Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

_FakeAdapter _install(_FakeAdapter a) {
  ApiService.dio.httpClientAdapter = a;
  return a;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('returns JSON responses, including 4xx with a server message', () async {
    _install(_FakeAdapter(
        status: 422,
        body: jsonEncode({'success': false, 'message': 'Invalid mobile'})));

    final res = await ApiService.post('send_otp', {'mobile': '1'});
    expect(res.statusCode, 422);
    expect(res.data['message'], 'Invalid mobile');
  });

  test('sends the stored token as a Bearer header', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'abc123'});
    final a = _install(_FakeAdapter(body: jsonEncode({'success': true})));

    await ApiService.get('/master_data');
    expect(a.lastRequest!.headers['Authorization'], 'Bearer abc123');
  });

  test('non-JSON body (e.g. an HTML 404 page) becomes a readable error',
      () async {
    _install(_FakeAdapter(
        status: 404, body: '<!DOCTYPE html><html></html>', contentType: 'text/html'));

    await expectLater(
      ApiService.post('does_not_exist', null),
      throwsA(isA<ApiException>()
          .having((e) => e.toString(), 'message', contains('Server error (404)'))),
    );
  });

  test('network failures map to friendly messages', () async {
    _install(_FakeAdapter(error: DioExceptionType.connectionError));
    await expectLater(
      ApiService.get('/x'),
      throwsA(isA<ApiException>()
          .having((e) => e.toString(), 'message', contains('No internet'))),
    );

    _install(_FakeAdapter(error: DioExceptionType.receiveTimeout));
    await expectLater(
      ApiService.get('/x'),
      throwsA(isA<ApiException>()
          .having((e) => e.toString(), 'message', contains('too long'))),
    );
  });

  test('401 without a token is returned, not treated as session expiry',
      () async {
    _install(_FakeAdapter(
        status: 401,
        body: jsonEncode({'success': false, 'message': 'Token is missing'})));

    final res = await ApiService.post('/user_profile', null);
    expect(res.statusCode, 401);
  });

  testWidgets('401 with a token ends the session and returns to Welcome',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'auth_token': 'expired', 'role_id': 2, 'user_id': '7'});
    _install(_FakeAdapter(
        status: 401,
        body: jsonEncode({
          'success': false,
          'message': 'Token has expired or is invalid.',
          'data': [],
        })));

    await tester.pumpWidget(const GetMaterialApp(
        home: Scaffold(body: Text('Dashboard'))));

    Object? error;
    await tester.runAsync(() async {
      try {
        await ApiService.post('/user_profile', null);
      } catch (e) {
        error = e;
      }
    });
    await tester.pumpAndSettle();

    expect(error, isA<ApiException>());
    expect((error as ApiException).isUnauthorized, isTrue);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.textContaining('session has expired'), findsOneWidget);

    // Let the notice time out so no timers are left pending.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
    await Get.deleteAll(force: true);
  });
}
