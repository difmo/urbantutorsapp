import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';

class LeadDetailPage extends StatelessWidget {
  final Map<String, String> enquiry;
  const LeadDetailPage({super.key, required this.enquiry});

  // ----- helpers to read flexible keys -----
  String _val(List<String> keys, [String fallback = '']) {
    for (final k in keys) {
      final v = enquiry[k];
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return fallback;
  }

  void _shareLead(BuildContext context) {
    final leadNo = _val(['lead', 'id'], '—');
    final dateTime = _val(['date', 'created_at'], '—');
    final clazz = _val(['class', 'course_name'], '—');
    final subject = _val(['subject', 'subject_name'], '—');
    final state = _val(['state', 'state_name'], '—');
    final locality = _val(['location', 'locality'], '—');
    final fee = _val(['fee', 'price'], '—');
    final mode = _val(['mode'], '—');
    final gender = _val(['tutor_gender', 'type_of_teacher'], 'Any');
    final note = _val(['remarks', 'remark', 'note'], '—');
    final coins = _val(['coins', 'coins_needed'], '—');
    final responded = _val(['responded'], '—');
    final name = _val(['student_name', 'name'], '—');
    final phone = _val(['mobile', 'phone'], '—');

    final text = '''
Tuition Lead #$leadNo
Date/Time: $dateTime

Class: $clazz
Subject: $subject
State: $state
Locality: $locality
Mode: $mode
Tutor Gender: $gender
Fee: $fee

Note: $note

Coins needed: $coins
Responded: $responded

Contact:
$name
$phone
''';

    Share.share(text, subject: 'Tuition Lead #$leadNo');
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = _val(['date', 'created_at'], '—');
    final leadNo = _val(['lead', 'id'], '—');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          dateTime,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () => _shareLead(context),
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
              children: [
                const Text("Lead No: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  leadNo,
                  style: const TextStyle(color: Color(0xFFFf9ba73)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            _buildDetailRow(
                Icons.book, "Class:", _val(['class', 'course_name'], '—')),
            _buildDetailRow(Icons.school, "Subject:",
                _val(['subject', 'subject_name'], '—')),
            _buildDetailRow(Icons.location_on, "Location:",
                _val(['state', 'state_name'], '—')),
            _buildDetailRow(
                Icons.map, "Locality:", _val(['location', 'locality'], '—')),
            _buildDetailRow(
                Icons.attach_money, "Fee:", _val(['fee', 'price'], '—')),
            _buildDetailRow(Icons.computer, "Mode:", _val(['mode'], '—')),
            _buildDetailRow(Icons.person, "Tutor Gender:",
                _val(['tutor_gender', 'type_of_teacher'], 'Any')),
            const SizedBox(height: 12),

            // Note
            const Text("Note:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              _val(['remarks', 'remark', 'note'],
                  'Required Only Professional Tutor.'),
              style: const TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 12),

            _buildDetailRow(Icons.credit_card, "Coins needed:",
                _val(['coins', 'coins_needed'], '300')),
            _buildDetailRow(
                Icons.group, "Responded:", _val(['responded'], '0 out of 3')),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGreenButton(
                  context,
                  "Upgrade Wallet",
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => TutorCoinsScreen())),
                ),
                _buildGreenButton(
                  context,
                  "Show Contact",
                  () => _showContactSheet(context),
                ),
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
                onPressed: () => _showVipSheet(context),
                child: const Text(
                  "Connect VIP Tutors Bureau",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      // 🔥 Removed the 3-dot FAB menu you asked to drop
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
                      text: value, style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Green button with custom onTap
  static Widget _buildGreenButton(
      BuildContext context, String text, VoidCallback onTap) {
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
          onPressed: onTap,
          child: Text(text,
              style: const TextStyle(fontSize: 14, color: Colors.white)),
        ),
      ),
    );
  }

  // -------------------- Bottom Sheets --------------------

  void _showContactSheet(BuildContext context) {
    final name = _val(['student_name', 'name'], 'Student');
    final phone = _val(['mobile', 'phone'], '');
    final area = _val(['location', 'locality'], '—');
    final mode = _val(['mode'], '—');

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetGrabber(),
              const SizedBox(height: 6),
              const Text('Contact Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _contactTile(Icons.person, 'Name', name),
              _contactTile(
                  Icons.phone, 'Phone', phone.isEmpty ? 'Not provided' : phone),
              _contactTile(Icons.location_on_outlined, 'Locality', area),
              _contactTile(Icons.computer, 'Mode', mode),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _pillAction(
                      icon: Icons.call,
                      label: 'Call',
                      onTap: phone.isEmpty
                          ? null
                          : () => _launchUrl('tel:$phone', context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _pillAction(
                      icon: Icons.chat_bubble_outline, // generic chat icon
                      label: 'WhatsApp',
                      onTap: phone.isEmpty
                          ? null
                          : () => _launchUrl(
                                'https://wa.me/$phone?text=Hi%2C%20I%20am%20interested%20in%20your%20tuition%20requirement.',
                                context,
                              ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _pillAction(
                      icon: Icons.copy,
                      label: 'Copy',
                      onTap: phone.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(
                                  ClipboardData(text: phone));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Number copied')));
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
void _showVipSheet(BuildContext context) {
  // Static VIP contact (change if you have dynamic values)
  const String vipName = 'VIP Tutors Bureau';
  const String vipPhone = '+919876543210';

  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetGrabber(),
            const SizedBox(height: 6),
            const Text(
              'VIP Contact',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _contactTile(Icons.person, 'Name', vipName),
            _contactTile(Icons.phone, 'Phone', vipPhone),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

  Widget _contactTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _pillAction(
      {required IconData icon, required String label, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.blue : Colors.grey.shade300,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _sheetGrabber() => Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open: $url')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to launch')),
        );
      }
    }
  }
}
