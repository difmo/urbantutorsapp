import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/grabbed_lead_model.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';

import 'package:urbantutorsapp/screens/tutor/enquiry_details_page_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/grabbed_lead_details_page.dart';

import '../../theme/theme_constants.dart';

class DashboardHomeTab extends StatefulWidget {
  const DashboardHomeTab({super.key});
  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab>
    with SingleTickerProviderStateMixin {
  // Separate ranges for each tab
  RangeValues _nearbyRange = const RangeValues(1, 15);
  RangeValues _allRange = const RangeValues(1, 50);

  late final TabController _tab; // <— to know which tab is active

  final TutorLeadsController _leads = Get.put(TutorLeadsController());
  late final CoinsController _coins;
  late final ProfileUpdateController _p;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: 1)
      ..addListener(() => setState(() {})); // rebuild when tab changes

    _coins = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    _coins.refreshAll();

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    // Tutor location is needed for distance filtering.
    if (_p.tutorprofileData.value == null) _p.fetchProfileForTutor();
  }

  bool _isGrabbed(TutorLead e) => _leads.grabbedFor(e.id) != null;

  /// Distance in km from the tutor's saved location to the lead, or null
  /// when either side has no coordinates.
  double? _distanceKm(TutorLead e) {
    final t = _p.tutorprofileData.value;
    final lat = double.tryParse(e.latitude.trim());
    final lng = double.tryParse(e.longitude.trim());
    if (t?.latitude == null || t?.longitude == null || lat == null || lng == null) {
      return null;
    }
    return Geolocator.distanceBetween(t!.latitude!, t.longitude!, lat, lng) /
        1000;
  }

  bool _isOffline(TutorLead e) => e.mode.trim().toLowerCase() == 'offline';

  /// Offline leads must lie within [range]; online leads are location-free.
  /// Leads without coordinates are kept (distance unknown).
  bool _inRange(TutorLead e, RangeValues range) {
    if (!_isOffline(e)) return true;
    final d = _distanceKm(e);
    return d == null || (d >= range.start - 1 && d <= range.end);
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: PreferredSize(
                    preferredSize:
                        const Size.fromHeight(40), // smaller than default
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        TabBar(
                          controller: _tab, // <—
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: Colors.white,
                          labelPadding: EdgeInsets.zero,
                          indicatorPadding: EdgeInsets.zero,
                          tabs: const [
                            Tab(
                                height: 48,
                                iconMargin: EdgeInsets.only(bottom: 2),
                                icon: Icon(Icons.location_on, size: 18),
                                text: "Nearby Enquiries"),
                            Tab(
                                height: 48,
                                iconMargin: EdgeInsets.only(bottom: 2),
                                icon: Icon(Icons.message, size: 18),
                                text: "All Enquiries"),
                            Tab(
                                height: 48,
                                iconMargin: EdgeInsets.only(bottom: 2),
                                icon: Icon(Icons.check_circle, size: 18),
                                text: "Connected"),
                          ],
                        ),
                      ],
                    ),
                  )),
              // ---- Select Range header (varies by tab) ----
              if (_tab.index == 0) ...[
                // Nearby: 1 – 15 km
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12),
                      const Text(
                        'Select Range:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_nearbyRange.start.round()} Km',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 5,
                              elevation: 0,
                              pressedElevation: 0,
                            ),
                            overlayShape:
                                const RoundSliderOverlayShape(overlayRadius: 0),
                            overlayColor: Colors.transparent,
                            activeTrackColor: AppColors.accentColor,
                            inactiveTrackColor: Colors.grey,
                            thumbColor: AppColors.accentColor,
                          ),
                          child: RangeSlider(
                            values: _nearbyRange,
                            min: 1,
                            max: 15,
                            divisions: 14,
                            labels: RangeLabels(
                              '${_nearbyRange.start.round()} km',
                              '${_nearbyRange.end.round()} km',
                            ),
                            onChanged: (v) => setState(() {
                              _nearbyRange = RangeValues(
                                v.start.clamp(1.0, 15.0),
                                v.end.clamp(1.0, 15.0),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '15 km',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ] else if (_tab.index == 1) ...[
                // All Enquiries: 1 – 50 km
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12),
                      const Text(
                        'Select Range:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_allRange.start.round()} Km',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 5,
                              elevation: 0,
                              pressedElevation: 0,
                            ),
                            overlayShape:
                                const RoundSliderOverlayShape(overlayRadius: 0),
                            overlayColor: Colors.transparent,
                            activeTrackColor: AppColors.accentColor,
                            inactiveTrackColor: Colors.grey,
                            thumbColor: AppColors.accentColor,
                          ),
                          child: RangeSlider(
                            values: _allRange,
                            min: 1,
                            max: 50,
                            divisions: 49,
                            labels: RangeLabels(
                              '${_allRange.start.round()} km',
                              '${_allRange.end.round()} km',
                            ),
                            onChanged: (v) => setState(() {
                              _allRange = RangeValues(
                                v.start.clamp(1.0, 50.0),
                                v.end.clamp(1.0, 50.0),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '50 km',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox.shrink(),
              ],
              Expanded(
                child: Obx(() {
                  if (_leads.isLoading.value && _leads.leads.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_leads.error.isNotEmpty && _leads.leads.isEmpty) {
                    return _ErrorRetry(
                      message: _leads.error.value,
                      onRetry: _leads.loadAvailable,
                    );
                  }
                  return TabBarView(
                    controller: _tab, // same controller as the TabBar
                    children: [
                      _nearbyTab(context),
                      _enquiryTab(context),
                      _contactedTab(context),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Tabs --------------------

  Widget _nearbyTab(BuildContext context) {
    final items = _leads.leads
        .where((e) => _isOffline(e) && _inRange(e, _nearbyRange))
        .toList();
    return RefreshIndicator(
      onRefresh: _leads.loadAvailable,
      child: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: Text(
                      'No offline enquiries in this range yet. Try a wider range.')),
            ), 
          ...items.map(
            (e) => GestureDetector(
              onTap: () => _openDetails(e),
              child: _LeadCard(
                lead: e,
                isContacted: _isGrabbed(e),
                distanceKm: _distanceKm(e),
                onReadMore: () => _openDetails(e),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enquiryTab(BuildContext context) {
    final items =
        _leads.leads.where((e) => _inRange(e, _allRange)).toList();
    return RefreshIndicator(
      onRefresh: _leads.refreshAll,
      child: items.isEmpty
          ? const Center(child: Text('No enquiries in this range yet'))
          : ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (_, i) {
                final e = items[i];
                final grabbed = _isGrabbed(e);
                return GestureDetector(
                  onTap: () => _openDetails(e),
                  child: _LeadCard(
                    lead: e,
                    isContacted: grabbed,
                    distanceKm: _distanceKm(e),
                    onReadMore: () => _openDetails(e),
                  ),
                );
              },
            ),
    );
  }

  /// CONTACTED = grabbed leads from server
  Widget _contactedTab(BuildContext context) {
    final items = _leads.grabbedLeads;
    return RefreshIndicator(
      onRefresh: _leads.loadGrabbed,
      child: items.isEmpty
          ? const Center(child: Text('No contacted (grabbed) leads yet'))
          : ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (_, i) {
                final e = items[i];
                return GestureDetector(
                  onTap: () => _openGrabDetails(e),
                  child: _GrabbedLeadCard(
                    lead: e,
                    isContacted: true,
                    onContactToggle: null,
                    onReadMore: () => _openGrabDetails(e),
                  ),
                );
              },
            ),
    );
  }

  void _openDetails(TutorLead e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeadDetailPage(
          enquiry: e,
        ),
      ),
    );
  }

  void _openGrabDetails(GrabLead e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrabbedLeadDetailsPage(enquiry: e),
      ),
    );
  }
}

// -------------------- helper widgets --------------------

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.lead,
    required this.isContacted,
    required this.onReadMore,
    this.distanceKm,
  });

  final TutorLead lead;
  final bool isContacted;
  final VoidCallback onReadMore;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.primaryColor),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Lead No: ',
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${lead.id}",
                      style: TextStyle(color: Colors.red),
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
            _kv(Icons.school, 'Name', lead.studentName),
            const SizedBox(height: 6),
            _kv(Icons.school, 'Class', lead.courseName),
            const SizedBox(height: 4),
            _kv(Icons.book, 'Subject', lead.subjectName),
            const SizedBox(height: 4),
            _kv(
                Icons.location_on,
                'Location',
                "${lead.location},${lead.state}"
                    "${distanceKm != null ? ' (${distanceKm!.toStringAsFixed(1)} km away)' : ''}"),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Mode + max tutors (lead_count)
                LeadMetaRow(
                  icon: Icons.switch_video, // pick any icon you prefer
                  label: 'Mode',
                  value: lead.mode,
                  iconColor: AppColors.accentColor,
                  trailing: (int.tryParse(lead.leadCount) ?? 0) > 0
                      ? leadCountPill('Max ${lead.leadCount}')
                      : null,
                ),
                const SizedBox(height: 6),

                // Row 2: Fee + "(Read more)" + right-aligned status
                LeadMetaRow(
                  icon: Icons.attach_money,
                  label: 'Fee',
                  value: "₹${lead.price}/Hr",
                  iconColor: AppColors.accentColor,
                  inlineLinkText: '(Read more)',
                  onInlineLinkTap: onReadMore,
                  trailing: isContacted
                      ? const Text(
                          'Contacted',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
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
                    fontWeight: FontWeight.w400, // normal value
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

class _GrabbedLeadCard extends StatelessWidget {
  const _GrabbedLeadCard({
    required this.lead,
    required this.isContacted,
    required this.onContactToggle,
    required this.onReadMore,
  });

  final GrabLead lead;
  final bool isContacted;
  final VoidCallback? onContactToggle; // null => disabled
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lead.studentName.isEmpty
                      ? 'Lead #${lead.leadId}'
                      : lead.studentName,
                  style: const TextStyle(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            _kv(Icons.school, 'Class', lead.courseName),
            const SizedBox(height: 4),
            _kv(Icons.book, 'Subject', lead.subjectName),
            const SizedBox(height: 4),
            _kv(Icons.location_on, 'Location', lead.location),
            const SizedBox(height: 4),
            _kv(Icons.computer, 'Mode', lead.mode),
            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.attach_money,
                    size: 18, color: AppColors.accentColor),
                const SizedBox(width: 4),
                Text(
                  '₹${lead.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onContactToggle,
                  icon: Icon(
                    isContacted ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                  ),
                  label: Text(isContacted ? 'Grabbed' : 'Mark Contacted'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: isContacted ? Colors.green : Colors.blue.shade200,
                    ),
                    foregroundColor:
                        isContacted ? Colors.green : AppColors.primaryColor,
                    minimumSize: const Size(0, 36),
                  ),
                ),
                const SizedBox(width: 8),
                // ElevatedButton(
                //   onPressed: onReadMore,
                //   style: ElevatedButton.styleFrom(
                //     minimumSize: const Size(0, 36),
                //     padding: const EdgeInsets.symmetric(horizontal: 12),
                //   ),
                //   child: const Text('Read More'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _kv(IconData icon, String k, String v) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentColor, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text('$k: $v',
              style: const TextStyle(color: AppColors.textColor)),
        ),
      ],
    );
  }
}

// --- Reusable row ------------------------------------------------------------
class LeadMetaRow extends StatelessWidget {
  const LeadMetaRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = Colors.green,
    this.trailing,
    this.inlineLinkText,
    this.onInlineLinkTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  /// Right-side widget (e.g., badge pill or status text)
  final Widget? trailing;

  /// Optional "(Read more)" link shown inline after `value`
  final String? inlineLinkText;
  final VoidCallback? onInlineLinkTap;

  @override
  Widget build(BuildContext context) {
    const baseColor = AppColors.textColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        // Left text block (label bold + value + optional link)
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: baseColor, fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                if (inlineLinkText != null) ...[
                  const TextSpan(text: ' '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: onInlineLinkTap,
                      child: Text(
                        inlineLinkText!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// --- Right-side pill badge ---------------------------------------------------
Widget leadCountPill(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF38A3FF),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );
}
