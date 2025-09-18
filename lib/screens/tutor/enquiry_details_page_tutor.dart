import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';

class LeadDetailPage extends StatelessWidget {
  final Map<String, String> enquiry;
  const LeadDetailPage({super.key, required this.enquiry});

  // Access controller (use existing instance if already put)
  TutorLeadsController get _leads => Get.isRegistered<TutorLeadsController>()
      ? Get.find<TutorLeadsController>()
      : Get.put(TutorLeadsController());

  // ----- helpers to read flexible keys -----
  String _val(List<String> keys, [String fallback = '']) {
    for (final k in keys) {
      final v = enquiry[k];
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return fallback;
  }

  // Try to read the "grab record id" (required by decline API)
  String? _grabId() {
    // common possibilities coming from various payloads
    final candidates = <String>[
      'grab_lead_id', 'grab_id', 'grablead_id',
      'id',
    ];
    final got = _val(candidates, '');
    return got.isEmpty ? null : got;
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
    final grabId = _grabId(); // if null → decline is not available
  print("Grab ID: $grabId");
  print ("Enquiry Data: $enquiry");
  print("Enquiry Keys: ${enquiry.keys.toList()}");
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
                  style: const TextStyle(color: Colors.blueAccent),
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

            if (grabId != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.thumb_down_alt, color: Colors.red),
                  label: const Text(
                    "Decline Lead",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _promptDecline(context, grabId),
                ),
              )
            else
              const SizedBox.shrink(),
            SizedBox(height: grabId != null ? 12 : 0),
            // Action Buttons (Upgrade + Show contact)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBlueButton(
                  context,
                  "Upgrade Wallet",
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TutorCoinsScreen())),
                ),
                _buildBlueButton(
                  context,
                  "Show Contact",
                  () => _showContactSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Decline Lead (visible only if we have a grab record id)

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

  /// Primary blue button
  static Widget _buildBlueButton(
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

  // -------------------- Decline flow --------------------

  void _promptDecline(BuildContext context, String grabLeadId) {
    final txt = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline Lead'),
        content: TextField(
          controller: txt,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add a short remark (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final remark =
                  txt.text.trim().isEmpty ? 'Lead declined' : txt.text.trim();
              try {
                // API expects: user_id (from storage inside service), grab_lead_id, remark
                final ss = await _leads.declineLead(
                    grabLeadId: grabLeadId, remark: remark);
                // Refresh both grabbed & declined lists
                print(ss);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lead declined successfully')),
                  );
                  Navigator.pop(context); // go back to list
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to decline: $e')),
                  );
                }
              }
            },
            child: const Text('CONFIRM', style: TextStyle(color: Colors.red)),
          ),
        ],
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
                      icon: Icons.chat_bubble_outline,
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
