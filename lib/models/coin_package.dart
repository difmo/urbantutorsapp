// lib/models/coin_package.dart
class CoinPackage {
  final int id;
  final int coins;
  final String amount; // "700.00"
  final String discountAmount; // "0.00"
  final int? discountPercentage; // can be null
  final int offers; // 1 = offer active
  final String? startDate;
  final String? endDate;
  final String description;
  final int status;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.amount,
    required this.discountAmount,
    required this.discountPercentage,
    required this.offers,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.status,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> j) => CoinPackage(
        id: j['id'] as int,
        coins: j['coins'] as int,
        amount: (j['amount'] ?? '0').toString(),
        discountAmount: (j['DiscountAmount'] ?? '0').toString(),
        discountPercentage: j['DiscountPercentage'] == null
            ? null
            : (j['DiscountPercentage'] as num).toInt(),
        offers: (j['offers'] ?? 0) as int,
        startDate: j['start_date']?.toString(),
        endDate: j['EndDate']?.toString(),
        description: (j['description'] ?? '').toString(),
        status: (j['status'] ?? 0) as int,
      );

  double get baseAmount => double.tryParse(amount) ?? 0.0;
  double get flatOff => double.tryParse(discountAmount) ?? 0.0;
  bool get hasPercentOffer =>
      offers == 1 && (discountPercentage ?? 0) > 0;

  /// Amount after discount (never < 0)
  double get effectiveAmount {
    double v = baseAmount;
    if (hasPercentOffer) {
      v = v * (1 - (discountPercentage! / 100.0));
    } else if (flatOff > 0) {
      v = v - flatOff;
    }
    if (v < 0) v = 0;
    return v;
  }

  /// GST 12%
  double get gst => effectiveAmount * 0.12;

  /// Payable
  double get total => effectiveAmount + gst;
}
