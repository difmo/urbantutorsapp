import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/enquiry_details_page_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  final TutorLeadsController _leads = Get.put(TutorLeadsController());

  RangeValues _currentRangeValues = const RangeValues(1, 10);

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        endDrawer: TutorDrawer(onMenuTap: (label) async {
          if (label == 'Logout') {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', false);
            await prefs.remove('user_name');
            await prefs.remove('user_phone');
            await prefs.remove('user_role');
            await StorageService.clearTokenAndRole();

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully')),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false,
            );
          }
        }),
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 2,
          toolbarHeight: 75,
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
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
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Welcome, Tutor',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TutorCoinsScreen()));
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on,
                            color: accentColor, size: 14),
                        const SizedBox(width: 6),
                        const Text(
                          "200 coins",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
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
          if (_leads.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_leads.error.isNotEmpty) {
            return _ErrorRetry(
              message: _leads.error.value,
              onRetry: _leads.load,
            );
          }

          return TabBarView(
            children: [
              _nearbyTab(context), // Offline only
              _enquiryTab(context), // All leads
              _contactedTab(context), // Marked as contacted
            ],
          );
        }),
      ),
    );
  }

  // ---------- Nearby
  Widget _nearbyTab(BuildContext context) {
    final items = _leads.nearby;
    return RefreshIndicator(
      onRefresh: _leads.refreshNow,
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
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                    });
                  },
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
          ...items.map((e) => _LeadCard(
                lead: e,
                isContacted: _leads.contactedIds.contains(e.id),
                onContactToggle: () => _leads.toggleContacted(e.id),
                onReadMore: () => _openDetails(e),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------- Enquiry (all)
  Widget _enquiryTab(BuildContext context) {
    final items = _leads.enquiries;
    return RefreshIndicator(
      onRefresh: _leads.refreshNow,
      child: items.isEmpty
          ? const Center(child: Text('No leads yet'))
          : ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (_, i) {
                final e = items[i];
                return _LeadCard(
                  lead: e,
                  isContacted: _leads.contactedIds.contains(e.id),
                  onContactToggle: () => _leads.toggleContacted(e.id),
                  onReadMore: () => _openDetails(e),
                );
              },
            ),
    );
  }

  // ---------- Contacted (local toggle)
  Widget _contactedTab(BuildContext context) {
    final items = _leads.contacted;
    return RefreshIndicator(
      onRefresh: _leads.refreshNow,
      child: items.isEmpty
          ? const Center(child: Text('No contacted leads yet'))
          : ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (_, i) {
                final e = items[i];
                return _LeadCard(
                  lead: e,
                  isContacted: true,
                  onContactToggle: () => _leads.toggleContacted(e.id),
                  onReadMore: () => _openDetails(e),
                );
              },
            ),
    );
  }

  void _openDetails(TutorLead e) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => LeadDetailPage(enquiry: e.toMap()), // your page expects a Map
    //   ),
    // );
  }
}

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
    required this.onContactToggle,
    required this.onReadMore,
  });

  final TutorLead lead;
  final bool isContacted;
  final VoidCallback onContactToggle;
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
                        color: AppColors.textColor)),
                const Spacer(),

                // Contacted toggle (kept compact to avoid infinite width)
                OutlinedButton.icon(
                  onPressed: onContactToggle,
                  icon: Icon(
                      isContacted ? Icons.check_circle : Icons.circle_outlined,
                      size: 18),
                  label: Text(isContacted ? 'Contacted' : 'Mark Contacted'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                        color:
                            isContacted ? Colors.green : Colors.blue.shade200),
                    foregroundColor:
                        isContacted ? Colors.green : AppColors.primaryColor,
                    minimumSize: const Size(0, 36),
                  ),
                ),
                const SizedBox(width: 8),

                // Read more
                ElevatedButton(
                  onPressed: onReadMore,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Read More'),
                ),
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
        child:
            Text('$k: $v', style: const TextStyle(color: AppColors.textColor)),
      ),
    ]);
  }

  static String _fmtDate(DateTime d) {
    // simple dd MMM yyyy
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
