// lib/controllers/coins_controller.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/coin_package.dart';
import 'package:urbantutorsapp/models/my_coins.dart';
import 'package:urbantutorsapp/services/coin_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
// lib/controllers/coins_controller.dart
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CoinsController extends GetxController {
  final CoinService _service = CoinService();

  // Packs
  final coins = <CoinPackage>[].obs;
  final loadingCoins = false.obs;
  final errorMessage = ''.obs;

  // Wallet + transactions
  final myCoins = Rxn<MyCoinsData>();
  final txns = <CoinTxn>[].obs;
  final loadingMyCoins = false.obs;
  final myCoinsError = ''.obs;

  // Orders
  final isCreatingOrder = false.obs;

  // Razorpay
  Razorpay? _razorpay;

  // ⚠️ Use only KEY_ID in the app (test)
  static const String _rzpKeyId = 'rzp_test_G8C4fq7TzDzwgm';
  @override
  void onInit() {
    super.onInit();
    super.onInit();
    fetchCoins();
    fetchMyCoins();
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpay ??= Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }


  @override
  void onClose() {
    _razorpay?.clear();
    super.onClose();
  }

  void _toast(BuildContext ctx, String msg) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> startRazorpayCheckout(
      BuildContext context, CoinPackage pack) async {
    final token = await StorageService
        .getToken(); // unused here but keep if you later call your server
    final userId = await StorageService.getUserId();
    if (token == null || userId == null) {
      _toast(context, 'Please login');
      return;
    }

    final amountPaise = (pack.total * 100).round().clamp(100, 999999999);

    try {
      isCreatingOrder.value = true;

      // 👇 Create order directly on Razorpay (since your server endpoint 404s)
      final orderId = await _service.createRazorpayOrderDirect(
        amountPaise: amountPaise,
        receipt: 'rcpt_${DateTime.now().millisecondsSinceEpoch}_$userId',
        notes: {
          'user_id': userId,
          'coins': '${pack.coins}',
          'package_id': '${pack.id ?? ''}',
        },
      );

      // Open checkout with that orderId
      final options = {
        'key': _rzpKeyId,
        'amount': amountPaise, // paise
        'currency': 'INR',
        'name': 'Urban Tutors',
        'description': '${pack.coins} Coins',
        'order_id': orderId, // 🔥 required
        'theme': {'color': '#5AB55E'},
      };

      _razorpay ??= Razorpay();
      _razorpay!.open(options);
    } catch (e) {
      _toast(context, 'Order error: $e');
    } finally {
      isCreatingOrder.value = false;
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse r) async {
    print(
        "Payment successful: ${r.paymentId}, order: ${r.orderId}, signature: ${r.signature}");  
    // Verify with backend (mandatory)
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    if (token == null || userId == null) return;

    final ok = await _service.verifyRazorpayPayment(
      userId: userId,
      razorpayOrderId: r.orderId ?? '',
      razorpayPaymentId: r.paymentId ?? '',
      razorpaySignature: r.signature ?? '',
      token: token,
    );
    if (ok) {
      print("Payment successful and verified $ok");
      Get.snackbar('Payment', 'Payment successful 🎉');
      // Refresh wallet/txns if you expose these:
      await refreshAll(); // make sure this only updates Rx after first frame
    } else {
         print("Payment successful and verified $ok");
      Get.snackbar('Payment', 'Verification failed',
          backgroundColor: Colors.red.shade100);
    }
  }

  void _onPaymentError(PaymentFailureResponse r) {
    print("Payment failed: ${r.code}: ${r.message ?? ''}");
    Get.snackbar('Payment failed', '${r.code}: ${r.message ?? ''}',
        backgroundColor: Colors.red.shade100);
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    print("External wallet: ${r.walletName ?? ''}");
    Get.snackbar('External wallet', r.walletName ?? '');
  }

  Future<void> fetchCoins() async {
    try {
      loadingCoins.value = true;
      errorMessage.value = '';
      final token = await StorageService.getToken();
      if (token == null) throw Exception('Auth token missing');
      final res = await _service.fetchPackages(token: token);
      coins.assignAll(res);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      loadingCoins.value = false;
    }
  }

  Future<void> fetchMyCoins() async {
    try {
      loadingMyCoins.value = true;
      myCoinsError.value = '';
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();
      if (token == null || userId == null) throw Exception('Not logged in');
      final data = await _service.fetchMyCoins(userId: userId, token: token);
      myCoins.value = data;
      txns.assignAll(data.details);
    } catch (e) {
      myCoinsError.value = e.toString();
    } finally {
      loadingMyCoins.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchCoins(), fetchMyCoins()]);
  }

  // -------------------- QUINCE (kept) --------------------
  Future<void> checkoutQuince(BuildContext context, CoinPackage pack) async {
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    if (token == null || userId == null) {
      _toast(context, 'Please login');
      return;
    }
    try {
      isCreatingOrder.value = true;
      final _ = await _service.createQuinceOrder(
        pack: pack,
        userId: userId,
        token: token,
      );
      // TODO: open URL if your API returns one
    } catch (e) {
      _toast(context, e.toString());
    } finally {
      isCreatingOrder.value = false;
    }
  }

  /// Create a Razorpay order directly (TEST keys). Returns order_id like "order_ABC..."
  Future<String> createRazorpayOrderDirect({
    required String keyId,
    required String keySecret,
    required int amountPaise, // integer paise
    String currency = 'INR',
    String? receipt,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.razorpay.com/v1/',
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}',
        'Content-Type': 'application/json',
      },
    ));

    final resp = await dio.post('orders', data: {
      'amount': amountPaise,
      'currency': currency,
      'receipt': receipt ?? 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
      'payment_capture': 1,
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final id = (resp.data['id'] ?? '').toString();
      if (id.isNotEmpty) return id;
    }
    throw Exception(
        'Failed to create Razorpay order: ${resp.statusCode} ${resp.data}');
  }

  /// Call your `/api/purchasecoins` (already implemented in service)
  Future<bool> verifyRazorpayAndRefresh({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required BuildContext context,
  }) async {
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    if (token == null || userId == null) {
      _toast(context, 'Please login');
      return false;
    }
    try {
      final ok = await _service.verifyRazorpayPayment(
        userId: userId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        token: token,
      );
      if (ok) await fetchMyCoins();
      return ok;
    } catch (e) {
      _toast(context, e.toString());
      return false;
    }
  }
}
