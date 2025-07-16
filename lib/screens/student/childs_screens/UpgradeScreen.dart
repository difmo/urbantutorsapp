import 'package:flutter/material.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Choose Your Plan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Unlock premium features and get more learning benefits!",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Plan Cards
            _buildPlanCard(
              context,
              title: 'Basic Plan',
              price: '₹199/month',
              coins: '100 Coins',
              features: [
                'Access PDF Courses',
                'Private Chat Support',
                'Limited Live Classes',
              ],
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: 'Premium Plan',
              price: '₹499/month',
              coins: 'Unlimited Coins',
              features: [
                'All Basic Plan Features',
                'Unlimited Live Classes',
                '1-on-1 Private Tutor Sessions',
                'Priority Support',
              ],
              isPopular: true,
            ),
            const SizedBox(height: 24),

            // One-time Purchase
            const Text(
              "Buy Coins",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _coinTile(context, '₹49', '50 Coins'),
                _coinTile(context, '₹99', '120 Coins'),
                _coinTile(context, '₹199', '300 Coins'),
                _coinTile(context, '₹499', '1000 Coins'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String coins,
    required List<String> features,
    bool isPopular = false,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular ? primaryColor.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isPopular ? primaryColor : Colors.grey.shade300,
          width: isPopular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          if (isPopular) const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(price,
              style: TextStyle(
                  fontSize: 14, color: Colors.black.withOpacity(0.8))),
          const SizedBox(height: 4),
          Text(coins, style: const TextStyle(color: Colors.orange)),
          const SizedBox(height: 8),
          ...features.map((f) => Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(f)),
                ],
              )),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Upgrade logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Upgrade Now'),
          )
        ],
      ),
    );
  }

  Widget _coinTile(BuildContext context, String price, String coins) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        // Handle coin purchase
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(coins,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(price,
                style: const TextStyle(
                    fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
