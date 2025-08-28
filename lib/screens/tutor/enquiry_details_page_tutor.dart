import 'package:flutter/material.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';

class LeadDetailPage extends StatelessWidget {
  final Map<String, String> enquiry;
  const LeadDetailPage({super.key, required this.enquiry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Aug 26, 2025 11:17 AM",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // TODO: Add share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lead Number
            Row(
              children: const [
                Text("Lead No: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("489", style: TextStyle(color: Color(0xFFFf9ba73))),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            _buildDetailRow(Icons.book, "Class:", "12th NIOS"),
            _buildDetailRow(Icons.school, "Subject:", "Biology, English"),
            _buildDetailRow(Icons.location_on,
                "Location:", "Gautam Buddha Nagar - Uttar Pradesh"),
            _buildDetailRow(Icons.map, "Locality:",
                "Pi 2, Pi I & II, Greater Noida"),
            _buildDetailRow(Icons.attach_money, "Fee:", "₹700/Hrs"),
            _buildDetailRow(Icons.computer, "Mode:", "Offline"),
            _buildDetailRow(Icons.person, "Tutor Gender:", "Any"),

            const SizedBox(height: 12),

            // Note
            const Text(
              "Note:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              "Required Only Professional Tutor.",
              style: TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 12),

            _buildDetailRow(Icons.credit_card, "Coins needed:", "300"),
            _buildDetailRow(Icons.group, "Responded:", "0 out of 3"),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGreenButton(context, "Upgrade Wallet"),
                _buildGreenButton(context, "Show Contact"),
              ],
            ),
            const SizedBox(height: 12),

            // VIP Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Connect VIP Tutors Bureau",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Row with icon + label + value
  static Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                      text: "$label ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: value,
                      style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Green button with navigation
  static Widget _buildGreenButton(BuildContext context, String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TutorCoinsScreen()),
            );
          },
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
