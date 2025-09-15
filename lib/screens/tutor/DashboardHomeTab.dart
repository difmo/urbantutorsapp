import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/grabbed_lead_model.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';

import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/enquiry_details_page_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/grabbed_lead_details_page.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';

import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';
import '../../theme/theme_constants.dart';

class DashboardHomeTab extends StatefulWidget {
  const DashboardHomeTab({super.key});
  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab> {
  RangeValues _currentRangeValues = const RangeValues(1, 10);

  final TutorLeadsController _leads = Get.put(TutorLeadsController());

  late final CoinsController _coins;

  @override
  void initState() {
    super.initState();
    _coins = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    _coins.refreshAll(); // loads coin packs + wallet
  }

  Future<void> _handleMenuTap(String label) async {
    Navigator.of(context).pop();
    if (label == 'Logout') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await StorageService.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (_) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Navigating to $label')));
    }
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  bool _isGrabbed(TutorLead e) =>
      _leads.grabbedLeads.any((g) => g.grabLeadId == e.id);

  Future<void> _grabThisLead(TutorLead e) async {
    final msg = await _leads.grabLead(e.id.toString());
    if (!mounted) return;
    if (msg != null) {
      Get.snackbar('Success', msg,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } else if (_leads.error.isNotEmpty) {
      Get.snackbar('Error', _leads.error.value,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        endDrawer: TutorDrawer(onMenuTap: _handleMenuTap),
        appBar: AppBar(
          backgroundColor: primary,
          elevation: 2,
          toolbarHeight: 75,
          title: Obx(() {
            final loading =
                _coins.loadingCoins.value || _coins.loadingMyCoins.value;
            final wallet = _coins.myCoins.value;
            final balance = _toNum(wallet?.available).toStringAsFixed(0);

            if (loading && wallet == null) {
              return const SizedBox(
                height: 24,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primary, accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 24,
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Welcome, Tutor',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TutorCoinsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '$balance coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
          bottom: const TabBar(
            labelColor: AppColors.accentColor,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accentColor,
            tabs: [
              Tab(text: "Nearby", icon: Icon(Icons.location_on)),
              Tab(text: "ENQUIRY", icon: Icon(Icons.message)),
              Tab(text: "CONTACTED", icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: Obx(() {
          if (_leads.isLoading.value && _leads.leads.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_leads.error.isNotEmpty && _leads.leads.isEmpty) {
            return _ErrorRetry(
                message: _leads.error.value, onRetry: _leads.loadAvailable);
          }

          return TabBarView(
            children: [
              _nearbyTab(context),
              _enquiryTab(context),
              _contactedTab(context),
            ],
          );
        }),
      ),
    );
  }

  // -------------------- Tabs --------------------

  Widget _nearbyTab(BuildContext context) {
    final items = _leads.nearby; // offline only
    return RefreshIndicator(
      onRefresh: _leads.loadAvailable,
      child: ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Range: ${_currentRangeValues.start.round()} km - ${_currentRangeValues.end.round()} km",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                RangeSlider(
                  values: _currentRangeValues,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  labels: RangeLabels(
                    "${_currentRangeValues.start.round()} km",
                    "${_currentRangeValues.end.round()} km",
                  ),
                  onChanged: (v) => setState(() => _currentRangeValues = v),
                  activeColor: AppColors.accentColor,
                  inactiveColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No nearby (offline) leads found')),
            ),
          ...items.map((e) => GestureDetector(
                onTap: () => _openDetails(e),
                child: _LeadCard(
                  lead: e,
                  isContacted: _isGrabbed(e),
                  onContactToggle:
                      _isGrabbed(e) ? null : () => _grabThisLead(e),
                  onReadMore: () => {_openDetails(e)},
                ),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _enquiryTab(BuildContext context) {
    final items = _leads.declinedLeads;
    return RefreshIndicator(
      onRefresh: _leads.loadDeclined,
      child: items.isEmpty
          ? const Center(child: Text('No leads yet'))
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
                    onContactToggle: grabbed ? null : () => _grabThisLead(e),
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
                    onContactToggle: null, // already grabbed
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
          enquiry: e.toMap().map((k, v) => MapEntry(k, v?.toString() ?? '')),
        ),
      ),
    );
  }

  void _openGrabDetails(GrabLead e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrabbedLeadDetailsPage(
          enquiry: e,
        ),
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
                  onPressed: onRetry, child: const Text('Retry')),
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
    required this.onContactToggle,
    required this.onReadMore,
  });

  final TutorLead lead;
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
                      ? 'Lead #${lead.id}'
                      : lead.studentName,
                  style: const TextStyle(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  lead.createdAt != null ? _fmtDate(lead.createdAt!) : '',
                  style: const TextStyle(color: Colors.grey),
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
                Text('₹${lead.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    )),
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
    return Row(children: [
      Icon(icon, color: AppColors.accentColor, size: 18),
      const SizedBox(width: 6),
      Expanded(
          child: Text('$k: $v',
              style: const TextStyle(color: AppColors.textColor))),
    ]);
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
                Text('₹${lead.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    )),
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
    return Row(children: [
      Icon(icon, color: AppColors.accentColor, size: 18),
      const SizedBox(width: 6),
      Expanded(
          child: Text('$k: $v',
              style: const TextStyle(color: AppColors.textColor))),
    ]);
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
