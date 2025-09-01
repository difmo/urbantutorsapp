// lib/services/coin_service.dart
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
    final res =
        await ApiService.post('https://urbantutors.pro/api/my_coins', form,
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
      // send final payable (incl. GST/discount) if your backend expects it:
      'amount': pack.total.toStringAsFixed(2),
      'gateway': 'quince',
    };

    final res =
        await ApiService.post('https://urbantutors.pro/api/purchasecoins',
            payload, token: token);
    developer.log("purchasecoins(quince-init) → ${res.data}",
        name: 'CoinService');

    final ok = (res.statusCode == 200 || res.statusCode == 201);
    if (ok && res.data is Map && (res.data['success'] == true)) {
      return QuinceOrder.fromJson(res.data['data'] ?? res.data);
    }
    throw Exception(res.data?['message'] ?? 'Unable to create order');
  }

/// Create a Razorpay order on YOUR SERVER (server uses KEY_SECRET).
  /// Adjust the endpoint if yours differs.
  Future<String> createRazorpayOrder({
    required String userId,
    required int amountPaise, // INR in paise
    required String token,
  }) async {
    // You can send receipt/currency if your backend expects them
    final payload = {
      'user_id': userId,
      'amount': amountPaise,   // server must forward to Razorpay Orders API
      'currency': 'INR',
    };

    // Example endpoint name — change to your actual:
    final res = await ApiService.post(
      'https://urbantutors.pro/api/create_razorpay_order',
      payload,
      token: token,
    );

    // Expecting: { success: true, data: { order_id: 'order_xxx', amount: 12345 } }
    if (res.statusCode == 200 &&
        res.data is Map &&
        (res.data['success'] == true)) {
      final data = res.data['data'] ?? res.data;
      final orderId = (data['order_id'] ?? data['id'] ?? '').toString();
      if (orderId.isNotEmpty) return orderId;
    }
    throw Exception(res.data?['message'] ?? 'Failed to create Razorpay order');
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

    final res =
        await ApiService.post('https://urbantutors.pro/api/purchasecoins',
            form, token: token);
    developer.log("purchasecoins(razorpay-verify) → ${res.data}",
        name: 'CoinService');

    if (res.statusCode == 200 && res.data is Map) {
      // API returns {success: false/true, message: "..."}
      return res.data['success'] == true;
    }
    return false;
  }
}
