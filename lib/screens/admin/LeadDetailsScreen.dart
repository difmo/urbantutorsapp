import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/screens/admin/CreateLeadScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class LeadDetailsScreen extends StatefulWidget {
  StudentLead enquiry;
  LeadDetailsScreen({super.key, required this.enquiry});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends State<LeadDetailsScreen> {
  late final CoinsController _c;
  late final ProfileUpdateController _p;

  // Guarded init (avoids Get.find crash if not registered)
  late final PayCourseController _payCourseController =
      Get.isRegistered<PayCourseController>()
          ? Get.find<PayCourseController>()
          : Get.put(PayCourseController());

  @override
  void initState() {
    super.initState();

    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.refreshAll();
    });

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    _p.fetchProfileForStudent();

    // Debug (optional)
    // for (var course in _payCourseController.courses) {
    //   // ignore: avoid_print
    //   print(course.toJson());
    // }
  }

  TutorLeadsController get _leads => Get.isRegistered<TutorLeadsController>()
      ? Get.find<TutorLeadsController>()
      : Get.put(TutorLeadsController());

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  String _initial(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'S';
    return n.characters.first.toUpperCase();
  }

  String _firstName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'Student';
    final parts = n.split(RegExp(r'\s+'));
    return parts.first;
  }

  // ---------- Flexible map reader for mixed payloads ----------
  String _val(List<String> keys, [String fallback = '']) {
    try {
      // Try map first (some APIs send different keys)
      final raw = widget.enquiry.toMap();
      // Normalize to string map
      final m = raw.map((k, v) =>
          MapEntry(k.toString(), v == null ? '' : v.toString().trim()));
      for (final k in keys) {
        final v = m[k] ?? m[k.toLowerCase()] ?? m[k.toUpperCase()];
        if (v != null && v.isNotEmpty && v != 'null') return v;
      }
    } catch (_) {
      // fall back to typed fields on TutorLead
      for (final k in keys) {
        switch (k) {
          case 'id':
          case 'lead':
            return widget.enquiry.id.toString();
          case 'student_name':
          case 'name':
            return widget.enquiry.studentName;
          case 'class':
          case 'course_name':
            return widget.enquiry.courseName;
          case 'subject':
          case 'subject_name':
            return widget.enquiry.subjectName;
          case 'state':
          case 'state_name':
            return widget.enquiry.state;
          case 'location':
          case 'locality':
            return widget.enquiry.location;
          case 'price':
          case 'fee':
            return widget.enquiry.price.toString();
          case 'mode':
            return widget.enquiry.mode;
        }
      }
    }
    return fallback;
  }

  String? _grabId() {
    // if it doesn't exist, return null (decline hidden)
    final got = _val(['grab_lead_id', 'grab_id', 'grablead_id'], '');
    return got.isEmpty ? null : got;
  }

  void _shareLead(BuildContext context) {
    final leadNo = _val(['lead', 'id'], '—');
    final dateTime = _val(['date', 'created_at'], '—');
    final clazz = _val(['class', 'course_name'], widget.enquiry.courseName);
    final subject =
        _val(['subject', 'subject_name'], widget.enquiry.subjectName);
    final state = _val(['state', 'state_name'], widget.enquiry.state);
    final locality = _val(['location', 'locality'], widget.enquiry.location);
    final fee = _val(['fee', 'price'], widget.enquiry.price.toString());
    final mode = _val(['mode'], widget.enquiry.mode);
    final gender = _val(['tutor_gender', 'type_of_teacher'], 'Any');
    final note = _val(['remarks', 'remark', 'note'], '—');
    final coins = _val(['coins', 'coins_needed'], '—');
    final responded = _val(['responded'], '—');
    final name = _val(['student_name', 'name'], widget.enquiry.studentName);
    final phone = _val(['mobile', 'phone'], '');

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

Remark: $note

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
    final leadNo = _val(['lead', 'id'], widget.enquiry.id.toString());
    final grabId = _grabId();

    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 76,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Obx(() {
          // coins
          final loadingCoins = _c.loadingCoins.value || _c.loadingMyCoins.value;
          final wallet = _c.myCoins.value;
          final balanceNum = _toNum(wallet?.available);
          final balanceText = balanceNum.toStringAsFixed(0);

          // profile
          final prof = _p.studentprofileData.value;
          final name = prof?.studentName?.trim();
          final displayName = _firstName(name);

          if (loadingCoins && wallet == null && prof == null) {
            return const SizedBox(
              height: 24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          return _Header(
            primary: primary,
            accent: accent,
            initial: _initial(name),
            greeting: "Lead Details",
            name: displayName,
            balance: balanceText,
            onCoinTap: () => _shareLead(context), // fixed callback
          );
        }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: primary,
        onPressed: _openActions,
        child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LeadCard(
              lead: widget.enquiry,
              isContacted: false,
              onContactToggle: () {}, // hook up if needed
              onReadMore: () {},
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Text("Remark : ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _val(['remarks', 'remark', 'note'],
                      'Required Only Professional Tutor.'),
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.credit_card, "Coins needed:",
                _val(['coins', 'coins_needed'], '300')),
            _buildDetailRow(
                Icons.group, "Responded:", _val(['responded'], '0/3')),
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
              ),
            if (grabId != null) const SizedBox(height: 12),
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
          Icon(icon, size: 20, color: AppColors.accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: "$label ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  void _openActions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionTile(
              icon: Icons.edit_rounded,
              color: Colors.teal,
              label: 'Edit',
              onTap: () {
                Navigator.pop(context); // close sheet
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateLeadScreen(
                      lead: widget.enquiry,
                      edit:true,
                      repost: false,
                    ), // edit
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.repeat_rounded,
              color: Colors.indigo,
              label: 'Edit & Repost',
              onTap: () {
                Navigator.pop(context); // close sheet
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateLeadScreen(
                      lead: widget.enquiry,
                      edit:false,
                      repost: true, // <-- post as NEW
                    ),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.delete_rounded,
              color: Colors.redAccent,
              label: 'Delete',
              onTap: () {
                Navigator.pop(context); // close sheet
                _confirmDeleteLead();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLead() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete lead?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await _deleteLead();
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLead() async {
    try {
      // Adjust the method name if your controller uses a different one.
      // await _leads.deleteLead(widget.enquiry.id.toString());
      // if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Lead deleted')),
      // );
      Navigator.pop(context, true); // go back to list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

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
                  const TextSpan(
                    text: 'Name: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: label == 'Name' ? value : value,
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

class _Header extends StatelessWidget {
  const _Header({
    required this.primary,
    required this.accent,
    required this.onCoinTap,
    required this.balance,
    required this.initial,
    required this.greeting,
    required this.name,
  });

  final Color primary;
  final Color accent;
  final VoidCallback onCoinTap;
  final String balance;

  final String initial;
  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        // Coins chip
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onCoinTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(width: 1, color: AppColors.primaryColor)),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Text(
                      '$balance coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: onCoinTap,
          tooltip: 'Share lead',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// —— Lead card + meta rows —— ///
class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.lead,
    required this.isContacted,
    required this.onContactToggle,
    required this.onReadMore,
  });

  final StudentLead lead;
  final bool isContacted;
  final VoidCallback? onContactToggle; // null => disabled
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Lead No: ',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${lead.id}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                lead.createdAt != null ? _fmtDate(lead.createdAt!) : '',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),

          _kv(Icons.person, 'Name', lead.studentName),
          const SizedBox(height: 6),
          _kv(Icons.school, 'Board', lead.boardName),
          const SizedBox(height: 6),
          _kv(Icons.school, 'Class', lead.courseName),
          const SizedBox(height: 4),
          _kv(Icons.book, 'Subject', lead.subjectName),
          const SizedBox(height: 4),
          _kv(Icons.location_on, 'Location', "${lead.location}, ${lead.state}"),
          const SizedBox(height: 10),

          // Meta rows (like your screenshot)
          LeadMetaRow(
            icon: Icons.switch_video,
            label: 'Mode',
            value: lead.mode,
            iconColor: AppColors.accentColor,
            trailing: null,
          ),
          LeadMetaRow(
            icon: Icons.countertops,
            label: 'Max',
            value: lead.leadCount,
            iconColor: AppColors.accentColor,
            trailing: null,
          ),
          const SizedBox(height: 6),
          LeadMetaRow(
            icon: Icons.attach_money,
            label: 'Fee',
            value: "₹${lead.price}/Hr",
            iconColor: AppColors.accentColor,
            onInlineLinkTap: onContactToggle,
            trailing: null,
          ),
        ],
      ),
    );
  }

  static Widget _kv(IconData icon, String label, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentColor, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700, // bold label
                    color: AppColors.textColor,
                  ),
                ),
                TextSpan(
                  text: text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

/// Small row used for Mode/Fee with optional inline "(Read more)" and trailing chip/status
class LeadMetaRow extends StatelessWidget {
  const LeadMetaRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.inlineLinkText,
    this.onInlineLinkTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final String? inlineLinkText;
  final VoidCallback? onInlineLinkTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$label: ',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.textColor),
              ),
              Text(
                value,
                style: const TextStyle(color: AppColors.textColor),
              ),
              if (inlineLinkText != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onInlineLinkTap,
                  child: Text(
                    inlineLinkText!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

Widget leadCountPill(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF2EA1FF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(.12),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
