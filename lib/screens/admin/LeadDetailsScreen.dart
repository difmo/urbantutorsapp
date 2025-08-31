// lib/screens/admin/LeadDetailsScreen.dart
import 'package:flutter/material.dart';
import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/screens/admin/CreateLeadScreen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class LeadDetailsScreen extends StatefulWidget {
  final StudentLead lead;
  const LeadDetailsScreen({super.key, required this.lead});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ---------- helpers ----------
  String _s(Object? v, {String dash = '—'}) {
    final t = (v ?? '').toString().trim();
    return t.isEmpty ? dash : t;
  }

  String _fmtDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final months = const [
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
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} $h:$m $ampm';
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
              icon: Icons.repeat_rounded,
              color: Colors.indigo,
              label: 'Repost',
              onTap: () {
                Navigator.pop(context);
                // TODO: call repost API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Repost clicked')),
                );
              },
            ),
            _ActionTile(
              icon: Icons.edit_rounded,
              color: Colors.teal,
              label: 'Edit',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateLeadScreen(lead: widget.lead),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.delete_rounded,
              color: Colors.redAccent,
              label: 'Delete',
              onTap: () {
                Navigator.pop(context);
                // TODO: confirm + call delete API
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final primary = AppColors.primaryColor;

    // IMPORTANT: use lead.location (NOT lead.locality)
    final location = _s(lead.location);
    final state = _s(lead.state);
    final board = _s(lead.boardName);
    final cls = _s(lead.courseName);
    final subject = _s(lead.subjectName);
    final mode = _s(lead.mode);
    final fee = _s(lead.price);
    final gender = "Male";
    // _s((lead as dynamic).tutorGender, dash: 'Any'); // optional
    final note = _s(lead.remark, dash: '—');
    final createdAt = _fmtDateTime(_s(lead.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(createdAt,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.black87),
            onPressed: () {
              // TODO: share lead summary
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: primary,
        onPressed: _openActions,
        child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  // Lead No
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      const Text('Lead No:',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      const SizedBox(width: 8),
                      Text(_s(lead.id),
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.school_rounded,
                    label: 'Class',
                    child: _LinkText(
                        text: board.isNotEmpty ? '$cls • $board' : cls),
                  ),
                  _InfoRow(
                    icon: Icons.menu_book_rounded,
                    label: 'Subject',
                    child: _LinkText(text: subject),
                  ),
                  _InfoRow(
                    icon: Icons.place_rounded,
                    label: 'State',
                    child: _LinkText(text: '$location - $state'),
                  ),
                  _InfoRow(
                    icon: Icons.map_rounded,
                    label: 'Locality',
                    child: _LinkText(text: location),
                  ),
                  _InfoRow(
                    icon: Icons.attach_money_rounded,
                    label: 'Fee',
                    child: _LinkText(text: '₹$fee/Hrs'),
                  ),
                  _InfoRow(
                    icon: Icons.computer_rounded,
                    label: 'Mode',
                    child: _LinkText(text: mode),
                  ),
                  // _InfoRow(
                  //   icon: Icons.person_outline_rounded,
                  //   label: 'Tutor Gender',
                  //   child: _LinkText(text: gender),
                  // ),

                  const SizedBox(height: 10),
                  const Text('Note:',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  _LinkText(text: note),
                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.monetization_on_outlined,
                    label: 'Coins needed',
                    child: _LinkButton(
                      text: fee.isEmpty ? '—' : fee,
                      onTap: () {}, // could navigate to coin top-up
                    ),
                  ),
                  _InfoRow(
                    icon: Icons.group_outlined,
                    label: 'Responses',
                    child: _LinkText(text: '0 out of 3 Responded'),
                  ),
                  const SizedBox(height: 10),

                  // Contact card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ContactRow(
                          icon: Icons.badge_outlined,
                          label: 'Contact name',
                          value: _s(lead.studentName, dash: '—'),
                        ),
                        const SizedBox(height: 8),
                        _ContactRow(
                          icon: Icons.call_outlined,
                          label: 'Contact number',
                          value: _s(lead.mobile),
                        ),
                        const SizedBox(height: 8),
                        _ContactRow(
                            icon: Icons.alternate_email_outlined,
                            label: 'Contact email',
                            value: "email@example.com"
                            // _s((lead as dynamic).email),
                            ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.share_rounded),
                            onPressed: () {
                              // TODO: share contact
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tabs: Matched / Collected
                  TabBar(
                    controller: _tab,
                    labelColor: AppColors.accentColor,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: AppColors.accentColor,
                    tabs: const [
                      Tab(icon: Icon(Icons.wifi_tethering), text: 'Matched'),
                      Tab(
                          icon: Icon(Icons.download_done_rounded),
                          text: 'Collected'),
                    ],
                  ),
                  SizedBox(
                    height: 280,
                    child: TabBarView(
                      controller: _tab,
                      children: const [
                        _RadiusSearch(),
                        _NoData(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- small widgets ----------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label:',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.blue, decoration: TextDecoration.underline),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: _LinkText(text: text));
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}

class _RadiusSearch extends StatefulWidget {
  const _RadiusSearch();
  @override
  State<_RadiusSearch> createState() => _RadiusSearchState();
}

class _RadiusSearchState extends State<_RadiusSearch> {
  double searchRadius = 4.0;
  List<Map<String, String>> nearbyTutors = [];

  @override
  void initState() {
    super.initState();
    fetchTutors(searchRadius);
  }

  void fetchTutors(double radius) {
    setState(() {
      searchRadius = radius;
      nearbyTutors = [
        if (radius >= 2) {'phone': '+919971225774', 'name': 'Sagar Solanki'},
        if (radius >= 3) {'phone': '+919268037284', 'name': 'Jitendra Kumar'},
        if (radius >= 4)
          {'phone': '+917982204695', 'name': 'Dashrath Kumar Singh'},
        if (radius >= 5) {'phone': '+919369617364', 'name': 'Another Tutor'},
      ];
    });
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionTitle(
          "Search Nearby Leads in Radius of [${searchRadius.toInt()} Kms]",
        ),
        Slider(
          value: searchRadius,
          min: 1,
          max: 10,
          divisions: 9,
          label: '${searchRadius.toInt()} Kms',
          activeColor: AppColors.primaryColor,
          onChanged: (v) => fetchTutors(v),
        ),
        const SizedBox(height: 8),

        // ⬇️ This takes the remaining height (inside the 280px area) and scrolls
        Expanded(
          child: nearbyTutors.isEmpty
              ? const Center(
                  child: Text('No Data found',
                      style: TextStyle(color: Colors.black54)))
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: nearbyTutors.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tutor = nearbyTutors[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(tutor['phone'] ?? ''),
                      subtitle: Text(tutor['name'] ?? ''),
                      trailing: Icon(Icons.call,
                          color: AppColors.primaryColor.withOpacity(0.7)),
                      onTap: () {
                        // optional: launch dialer
                        // launchUrl(Uri.parse('tel:${tutor['phone']}'));
                      },
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No Data found', style: TextStyle(color: Colors.black54)),
    );
  }
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
