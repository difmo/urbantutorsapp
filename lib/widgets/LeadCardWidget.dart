import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class LeadCardWidget extends StatelessWidget {
  final String studentName;
  final String mobile;
  final String subject;
  final String classLevel;
  final String location;
  final String timing;
  final String coins;
  final String remarks;
  final VoidCallback onTap;

  const LeadCardWidget({
    super.key,
    required this.studentName,
    required this.mobile,
    required this.subject,
    required this.classLevel,
    required this.location,
    required this.timing,
    required this.coins,
    required this.remarks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person, color: primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Text(classLevel,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            // Details
            Row(
              children: [
                Icon(Icons.book_outlined, color: accent, size: 18),
                const SizedBox(width: 6),
                Text(subject, style: const TextStyle(fontSize: 14)),
                const Spacer(),
                Icon(Icons.schedule, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(timing, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(location, style: const TextStyle(fontSize: 14)),
                const Spacer(),
                Icon(Icons.phone, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(mobile, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            if (remarks.isNotEmpty)
              Text('📝 $remarks',
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 10),
            // Coins badge
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on, size: 16, color: accent),
                    const SizedBox(width: 4),
                    Text('$coins coins',
                        style:
                            TextStyle(color: accent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
