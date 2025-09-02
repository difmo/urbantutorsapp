// lib/models/my_coins.dart
class MyCoinsData {
  final double available;
  final double spent;
  final double total;
  final List<CoinTxn> details;

  MyCoinsData({
    required this.available,
    required this.spent,
    required this.total,
    required this.details,
  });

  factory MyCoinsData.fromJson(Map<String, dynamic> j) {
    double d(v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    final List list = (j['coinsDetails'] as List?) ?? const [];
    return MyCoinsData(
      available: d(j['total_Available_balance']),
      spent: d(j['total_spent_balance']),
      total: d(j['total_balance']),
      details:
          list.map((e) => CoinTxn.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class CoinTxn {
  final int id;
  final int userId;
  final String? orderId;
  final int status; // 1 = success, 0 = failed/pending (per backend)
  final String? receiptId;
  final double amount;
  final double finalAmount;
  final double coins;
  final double discountAmount;
  final double discountPercentage;
  final int offers;
  final DateTime? createdAt;

  CoinTxn({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.status,
    required this.receiptId,
    required this.amount,
    required this.finalAmount,
    required this.coins,
    required this.discountAmount,
    required this.discountPercentage,
    required this.offers,
    required this.createdAt,
  });

  factory CoinTxn.fromJson(Map<String, dynamic> j) {
    double d(v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    DateTime? t(v) => v == null ? null : DateTime.tryParse(v.toString());
    return CoinTxn(
      id: int.tryParse(j['id'].toString()) ?? 0,
      userId: int.tryParse(j['user_id'].toString()) ?? 0,
      orderId: j['order_id']?.toString(),
      status: int.tryParse(j['transaction_status'].toString()) ?? 0,
      receiptId: j['receipt_id']?.toString(),
      amount: d(j['amount']),
      finalAmount: d(j['final_amount']),
      coins: d(j['coins']),
      discountAmount: d(j['discount_amount']),
      discountPercentage: d(j['discount_percentage']),
      offers: int.tryParse(j['offers'].toString()) ?? 0,
      createdAt: t(j['created_at']),
    );
  }
}
