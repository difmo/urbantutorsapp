import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class LeadDetailsScreen extends StatefulWidget {
  final String studentName;
  final String mobile;
  final String subject;
  final String classLevel;
  final String location;
  final String timing;
  final String coins;
  final String remarks;

  const LeadDetailsScreen({
    super.key,
    required this.studentName,
    required this.mobile,
    required this.subject,
    required this.classLevel,
    required this.location,
    required this.timing,
    required this.coins,
    required this.remarks,
  });

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: primary),
        title: Text('Lead Details', style: TextStyle(color: primary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: accent.withOpacity(0.15),
                  child: Text(
                    widget.studentName[0].toUpperCase(),
                    style: TextStyle(fontSize: 28, color: accent, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.studentName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildInfoRow(Icons.school, 'Class', widget.classLevel),
          _buildInfoRow(Icons.book, 'Subject', widget.subject),
          _buildInfoRow(Icons.location_on, 'Location', widget.location),
          _buildInfoRow(Icons.schedule, 'Timing', widget.timing),
          _buildInfoRow(Icons.phone, 'Mobile', widget.mobile),
          _buildInfoRow(Icons.monetization_on, 'Coins Required', widget.coins, valueColor: Colors.orange),
          if (widget.remarks.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Remarks:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(widget.remarks, style: const TextStyle(fontSize: 15)),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Future.delayed(Duration(seconds: 2));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lead grabbed successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Grab Lead'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentColor, size: 20),
          const SizedBox(width: 12),
          Text("$title:", style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
