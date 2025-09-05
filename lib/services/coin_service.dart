// lib/services/coin_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/coin_package.dart';
import 'package:urbantutorsapp/models/my_coins.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'dart:developer' as developer;

class QuinceOrder {
  final String orderId;
  final String checkoutUrl;
  final String? successUrl;
  final String? failUrl;

  QuinceOrder({
    required this.orderId,
    required this.checkoutUrl,
    this.successUrl,
    this.failUrl,
  });

  factory QuinceOrder.fromJson(Map<String, dynamic> j) => QuinceOrder(
        orderId: (j['order_id'] ?? j['id'] ?? '').toString(),
        checkoutUrl: (j['checkout_url'] ?? j['payment_url'] ?? '').toString(),
        successUrl: j['success_url']?.toString(),
        failUrl: j['fail_url']?.toString(),
      );
}

class CoinService {
  /// Packs
  Future<List<CoinPackage>> fetchPackages({required String token}) async {
    developer.log("Fetching coin packages", name: 'CoinService');
    final res = await ApiService.get('https://urbantutors.pro/api/get_coins',
        token: token);
    developer.log("get_coins → ${res.data}", name: 'CoinService');

    if (res.statusCode == 200 &&
        res.data is Map &&
        res.data['success'] == true) {
      final List data = res.data['data'] as List;
      return data.map((e) => CoinPackage.fromJson(e)).toList();
    }
    throw Exception('Failed to load coin packages');
  }

  /// Wallet + transactions
  Future<MyCoinsData> fetchMyCoins({
    required String userId,
    required String token,
  }) async {
    final form = FormData.fromMap({'user_id': userId});
    final res = await ApiService.post(
        'https://urbantutors.pro/api/my_coins', form,
        token: token);
    developer.log("my_coins → ${res.data}", name: 'CoinService');

    if (res.statusCode == 200 &&
        res.data is Map &&
        res.data['success'] == true) {
      return MyCoinsData.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data?['message'] ?? 'Failed to load my coins');
  }

  /// Create Quince order (server returns checkout url)
  Future<QuinceOrder> createQuinceOrder({
    required CoinPackage pack,
    required String userId,
    required String token,
  }) async {
    final payload = {
      'user_id': userId,
      'package_id': pack.id,
      'coins': pack.coins,
      'amount': pack.total.toStringAsFixed(2),
      'gateway': 'quince',
    };

    final res = await ApiService.post(
        'https://urbantutors.pro/api/purchagecoins', payload,
        token: token);
    developer.log("purchasecoins(quince-init) → ${res.data}",
        name: 'CoinService');

    final ok = (res.statusCode == 200 || res.statusCode == 201);
    if (ok && res.data is Map && (res.data['success'] == true)) {
      return QuinceOrder.fromJson(res.data['data'] ?? res.data);
    }
    throw Exception(res.data?['message'] ?? 'Unable to create order');
  }

   // ⛳️ Test keys (OK for dev). For prod, NEVER embed KEY_SECRET in app.
  static const String rzpKeyId = 'rzp_test_G8C4fq7TzDzwgm';
  static const String rzpKeySecret = 'jx32K2TTW84b1Gj53IWAfFVf';

  // ---------- DIRECT Razorpay order create (TEST/DEV) ----------
  Future<String> createRazorpayOrderDirect({
    required int amountPaise,
    required String receipt,
    Map<String, dynamic>? notes,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.razorpay.com/v1/',
      headers: {
        // Basic Auth: key_id:key_secret
        'Authorization': 'Basic ${base64Encode(utf8.encode('$rzpKeyId:$rzpKeySecret'))}',
        'Content-Type': 'application/json',
      },
      receiveDataWhenStatusError: true,
      validateStatus: (_) => true,
    ));

    final body = {
      'amount': amountPaise,      // paise
      'currency': 'INR',
      'receipt': receipt,
      'payment_capture': 1,
      if (notes != null) 'notes': notes,
    };

    developer.log('RZP create order → $body', name: 'CoinService');

    final res = await dio.post('orders', data: body);

    developer.log('RZP resp [${res.statusCode}] → ${res.data}', name: 'CoinService');

    if (res.statusCode == 200 || res.statusCode == 201) {
      final id = res.data?['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    throw Exception('Razorpay order create failed: ${res.statusCode} ${res.data}');
  }

  /// Verify Razorpay success with your backend
  /// (fields per your Postman screenshot)
  Future<bool> verifyRazorpayPayment({
    required String userId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String token,
  }) async {
    final form = FormData.fromMap({
      'user_id': userId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    });

    final res = await ApiService.post(
        'https://urbantutors.pro/api/purchagecoins', form,
        token: token);
        print("Response from purchasecoins(razorpay-verify) → ${res.data}");

      
    if (res.statusCode == 200 && res.data is Map) {
      return res.data['success'] == true;
    }
    return false;
  }
}
