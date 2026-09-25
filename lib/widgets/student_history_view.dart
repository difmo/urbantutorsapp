import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/controllers/my_course_controller.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

/// A student's real activity: tutor requests they posted, coin purchases and
/// purchased courses, newest first.
class StudentHistoryView extends StatefulWidget {
  const StudentHistoryView({super.key});

  @override
  State<StudentHistoryView> createState() => _StudentHistoryViewState();
}

class _Entry {
  _Entry(this.icon, this.color, this.title, this.subtitle, this.date);
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime? date;
}

class _StudentHistoryViewState extends State<StudentHistoryView> {
  late final LeadController _leads;
  late final CoinsController _coins;
  late final MyCourseController _courses;

  @override
  void initState() {
    super.initState();
    _leads = Get.isRegistered<LeadController>()
        ? Get.find<LeadController>()
        : Get.put(LeadController());
    _coins = Get.find<CoinsController>();
    _courses = Get.isRegistered<MyCourseController>()
        ? Get.find<MyCourseController>()
        : Get.put(MyCourseController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() => Future.wait(
      [_leads.fetchLeads(), _coins.fetchMyCoins(), _courses.load()]);

  static String _date(DateTime? d) {
    if (d == null) return '';
    final l = d.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}/${l.year}';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Obx(() {
        final loading = _leads.isLoading.value ||
            _coins.loadingMyCoins.value ||
            _courses.isLoading.value;

        final entries = <_Entry>[
          ..._leads.studentLeads.map((l) => _Entry(
                Icons.search_rounded,
                AppColors.primaryColor,
                'Tutor request #${l.id}',
                [l.courseName, l.subjectName, l.mode]
                    .where((s) => s.trim().isNotEmpty)
                    .join(' • '),
                l.createdAt,
              )),
          ..._coins.txns.map((t) => _Entry(
                Icons.monetization_on_outlined,
                t.status == 1 ? Colors.green : Colors.orange,
                'Purchased ${t.coins.toStringAsFixed(0)} coins',
                '₹${t.finalAmount.toStringAsFixed(0)} • '
                    '${t.status == 1 ? 'Successful' : 'Pending'}',
                t.createdAt,
              )),
          ..._courses.courses.map((c) => _Entry(
                Icons.picture_as_pdf_outlined,
                Colors.redAccent,
                'Bought course: ${c.courseName}',
                '${c.coins} coins',
                c.createdAt,
              )),
        ]..sort((a, b) =>
            (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));

        if (loading && entries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (entries.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              Icon(Icons.history, size: 56, color: Colors.black26),
              SizedBox(height: 8),
              Center(
                child: Text('No activity yet',
                    style: TextStyle(color: Colors.black54, fontSize: 16)),
              ),
            ],
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final e = entries[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: e.color.withValues(alpha: 0.12),
                child: Icon(e.icon, color: e.color),
              ),
              title: Text(e.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(e.subtitle),
              trailing: Text(_date(e.date),
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            );
          },
        );
      }),
    );
  }
}
