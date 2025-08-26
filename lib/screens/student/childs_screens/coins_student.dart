import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class CoinsStudent extends StatelessWidget {
  final List<Map<String, dynamic>> coinPackages = [
    {"price": 100, "coins": 10},
    {"price": 3000, "coins": 2500},
    {"price": 5000, "coins": 5000},
    {"price": 7000, "coins": 7500},
    {"price": 15000, "coins": 21000},
  ];

  CoinsStudent({super.key});

  double calculateTotalWithGst(int price) {
    return price + (price * 0.12);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Wallet"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Recharge your wallet : 0 Coins left",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: coinPackages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pkg = coinPackages[index];
                return InkWell(
                  onTap: () {
                    _showCheckoutBottomSheet(
                      context,
                      pkg['price'],
                      pkg['coins'],
                      primaryColor,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₹${pkg['price']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${pkg['coins']} Coins",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text("Successful", style: TextStyle(fontSize: 14)),
                SizedBox(width: 16),
                Icon(Icons.error, color: Colors.red, size: 20),
                SizedBox(width: 6),
                Text("Failed", style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Transactions :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "No transactions available",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutBottomSheet(BuildContext context, int price, int coins, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final keyboardPadding = mediaQuery.viewInsets.bottom;
        final gstAmount = price * 0.12;
        final totalPrice = price + gstAmount;

        return Padding(
          padding: EdgeInsets.only(bottom: keyboardPadding),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: mediaQuery.size.height * 0.8,
                maxWidth: mediaQuery.size.width * 0.9,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Checkout",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 20),
                  Text("Coins: $coins"),
                  const SizedBox(height: 8),
                  Text("Base Price: ₹$price"),
                  const SizedBox(height: 8),
                  Text("GST (12%): ₹${gstAmount.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  Text("Total Payable: ₹${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Pay ₹${totalPrice.toStringAsFixed(2)}"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
