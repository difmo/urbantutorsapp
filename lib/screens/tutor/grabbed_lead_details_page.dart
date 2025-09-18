import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/grabbed_lead_model.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';

class GrabbedLeadDetailsPage extends StatelessWidget {
  final GrabLead enquiry;
  const GrabbedLeadDetailsPage({super.key, required this.enquiry});

  TutorLeadsController get _leads => Get.isRegistered<TutorLeadsController>()
      ? Get.find<TutorLeadsController>()
      : Get.put(TutorLeadsController());

  String _nz(String v, [String fb = '—']) => (v.trim().isEmpty) ? fb : v.trim();

  void _shareLead() {
    final text = '''
Tuition Lead #${enquiry.leadId}

Class: ${_nz(enquiry.courseName)}
Subject: ${_nz(enquiry.subjectName)}
State: ${_nz(enquiry.state)}
Locality: ${_nz(enquiry.location)}
Mode: ${_nz(enquiry.mode)}
Fee: ${_nz(enquiry.price)}

Coins needed: ${_nz(enquiry.coins)}

Student:
${_nz(enquiry.studentName)}
${_nz(enquiry.studentMobile)}
''';
    Share.share(text, subject: 'Tuition Lead #${enquiry.leadId}');
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Lead #${enquiry.leadId}';
    final grabId = enquiry.grabLeadId.toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: _shareLead,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text("Lead No: ",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${enquiry.leadId}',
                style: const TextStyle(color: Colors.blueAccent)),
          ]),
          const SizedBox(height: 12),

          _row(Icons.book, "Class:", _nz(enquiry.courseName)),
          _row(Icons.school, "Subject:", _nz(enquiry.subjectName)),
          _row(Icons.location_on, "State:", _nz(enquiry.state)),
          _row(Icons.map, "Locality:", _nz(enquiry.location)),
          _row(Icons.computer, "Mode:", _nz(enquiry.mode)),
          _row(Icons.attach_money, "Fee:", _nz(enquiry.price)),
          const SizedBox(height: 12),

          const Text("Note:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_nz(enquiry.remark, 'Required Only Professional Tutor.'),
              style: const TextStyle(color: Colors.blue)),
          const SizedBox(height: 12),

          _row(Icons.credit_card, "Coins needed:", _nz(enquiry.coins)),
          const SizedBox(height: 24),

          // Decline (grab record id exists by model)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.thumb_down_alt, color: Colors.red),
              label: const Text("Decline Lead",
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _promptDecline(context, grabId),
            ),
          ),
          const SizedBox(height: 12),

          Row(children: [
            _blueBtn(
                context,
                "Upgrade Wallet",
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TutorCoinsScreen()))),
            const SizedBox(width: 8),
            _blueBtn(context, "Show Contact", () => _showContactSheet(context)),
          ]),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showVipSheet(context),
              child: const Text("Connect VIP Tutors Bureau",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  // ---- Decline flow
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
                await _leads.declineLead(
                    grabLeadId: grabLeadId, remark: remark);
                _leads.grabbedLeads;
                _leads.declinedLeads;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lead declined successfully')),
                  );
                  Navigator.pop(context);
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

  // ---- Contact sheet
  void _showContactSheet(BuildContext context) {
    final name = _nz(enquiry.studentName, 'Student');
    final phone = _nz(enquiry.studentMobile, '');
    final area = _nz(enquiry.location);
    final mode = _nz(enquiry.mode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _grabber(),
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
            Row(children: [
              Expanded(
                  child: _pill(
                      icon: Icons.call,
                      label: 'Call',
                      onTap: phone.isEmpty
                          ? null
                          : () => _launch('tel:$phone', context))),
              const SizedBox(width: 8),
              Expanded(
                  child: _pill(
                      icon: Icons.chat_bubble_outline,
                      label: 'WhatsApp',
                      onTap: phone.isEmpty
                          ? null
                          : () => _launch(
                              'https://wa.me/$phone?text=Hi%2C%20I%20am%20interested%20in%20your%20tuition%20requirement.',
                              context))),
              const SizedBox(width: 8),
              Expanded(
                  child: _pill(
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
                                      content: Text('Number copied')),
                                );
                              }
                            })),
            ]),
            const SizedBox(height: 6),
          ]),
        );
      },
    );
  }

  void _showVipSheet(BuildContext context) {
    const vipName = 'VIP Tutors Bureau';
    const vipPhone = '+919876543210';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _grabber(),
          const SizedBox(height: 6),
          const Text('VIP Contact',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _contactTile(Icons.person, 'Name', vipName),
          _contactTile(Icons.phone, 'Phone', vipPhone),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // ---- UI helpers
  static Widget _row(IconData i, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(i, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
              child: RichText(
            text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                      text: "$k ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: v, style: const TextStyle(color: Colors.blue)),
                ]),
          )),
        ]),
      );

  static Widget _blueBtn(BuildContext c, String t, VoidCallback onTap) =>
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onTap,
          child: Text(t,
              style: const TextStyle(fontSize: 14, color: Colors.white)),
        ),
      );

  static Widget _contactTile(IconData icon, String label, String value) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
              child: RichText(
            text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ]),
          )),
        ]),
      );

  static Widget _pill(
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

  static Widget _grabber() => Center(
        child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(4))),
      );

  Future<void> _launch(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Cannot open: $url')));
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to launch')));
      }
    }
  }
}
