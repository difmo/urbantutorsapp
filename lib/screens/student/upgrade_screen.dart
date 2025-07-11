import 'package:flutter/material.dart';
import 'package:urbantutors_app/theme/theme_constants.dart';

class StudentUpgradeScreen extends StatelessWidget {
  const StudentUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Your Plan'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Plan Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Current Plan: Free",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Limited access to tutors, courses & features."),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upgrade Button
            ElevatedButton.icon(
              onPressed: () {
                // Add upgrade logic here
              },
              icon: const Icon(Icons.upgrade),
              label: const Text("Upgrade to Premium"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 16),

            // View Features
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to feature comparison
              },
              icon: const Icon(Icons.info_outline),
              label: const Text("View Premium Features"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const Spacer(),

            // Contact Support
            TextButton.icon(
              onPressed: () {
                // Navigate or open support chat
              },
              icon: const Icon(Icons.support_agent),
              label: const Text("Need Help? Contact Support"),
            )
          ],
        ),
      ),
    );
  }
}
