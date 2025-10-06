import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/transaction_controller.dart';
import 'package:urbantutorsapp/models/transaction_models.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';

class TransactionsTutor extends StatefulWidget {
  const TransactionsTutor({super.key});

  @override
  State<TransactionsTutor> createState() => _TransactionsTutorState();
}

class _TransactionsTutorState extends State<TransactionsTutor> {
  late final CoinsController _c;
  late final ProfileUpdateController _p;
  late final TransactionController _t;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());

    _t = Get.isRegistered<TransactionController>()
        ? Get.find<TransactionController>()
        : Get.put(TransactionController());

    // ✅ Defer reactive work to avoid setState/markNeedsBuild during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.refreshAll();
      _p.fetchProfileForStudent();
      _t.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawer: Tutordrawer(onMenuTap: (label) async {
        if (label == 'Logout') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);
          await prefs.remove('user_name');
          await prefs.remove('user_phone');
          await prefs.remove('user_role');
          await StorageService.clearTokenAndRole();
          await StorageService.clear();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigating to $label')),
          );
        }
      }),
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
          final loadingCoins = _c.loadingCoins.value || _c.loadingMyCoins.value;
          final wallet = _c.myCoins.value;
          final balanceNum = _toNum(wallet?.available);
          final balanceText = balanceNum.toStringAsFixed(0);

          final prof = _p.studentprofileData.value;
          final name = prof?.studentName?.trim() ?? '';
          final displayName =
              name.isEmpty ? 'Tutor' : name.split(RegExp(r'\s+')).first;

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
            initial: (displayName.isEmpty ? 'T' : displayName[0].toUpperCase()),
            greeting: "Transactions",
            name: displayName,
            balance: balanceText,
            onCoinTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TutorCoinsScreen()),
              );
            },
          );
        }),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 45,
              ),
              onPressed: () => Scaffold.maybeOf(ctx)?.openEndDrawer(),
            ),
          ),
        ],
      ),
      body: SafeArea(child: Obx(_buildBody)),
    );
  }

  /// ====== BODY (integrated here) ======
  Widget _buildBody() {
    if (_t.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_t.error.value.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: Colors.red),
              const SizedBox(height: 12),
              Text(_t.error.value, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _t.bootstrap,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_t.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _t.refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No transactions yet')),
          ],
        ),
      );
    }

    final credit = _t.totalCredit;
    final debit = _t.totalDebit;
    final net = _t.net;

    return RefreshIndicator(
      onRefresh: _t.refreshAll,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        itemCount: _t.items.length + 1, // +1 summary card
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SummaryCard(credit: credit, debit: debit, net: net);
          }
          final item = _t.items[index - 1];
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _TxnTile(item: item),
          );
        },
      ),
    );
  }
}

/// ====== Header (unchanged visually) ======
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
        const SizedBox(width: 8),
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
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onCoinTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(width: 1, color: AppColors.primaryColor),
                ),
                child: Row(
                  children: [
                    Text(
                      balance == "0" ? "Upgrade" : "$balance coins",
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
        const SizedBox(width: 8),
      ],
    );
  }
}

/// ====== Summary card ======
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.credit,
    required this.debit,
    required this.net,
  });

  final double credit;
  final double debit;
  final double net;

  @override
  Widget build(BuildContext context) {
    final pos = net >= 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _pill('Credit', credit, Icons.arrow_downward_rounded, Colors.green),
          const SizedBox(width: 10),
          _pill('Debit', debit, Icons.arrow_upward_rounded, Colors.red),
          const Spacer(),
          Text(
            '${pos ? '+' : '-'}₹${pos ? net.toStringAsFixed(2) : (-net).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: pos ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label ₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== Single transaction tile ======
class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.item});
  final TransactionEntry item;

  @override
  Widget build(BuildContext context) {
    final isCr = item.isCredit;
    final amount = isCr ? item.credit : item.debit;
    final color = isCr ? Colors.green : Colors.red;
    final icon  = isCr ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: _middle(item)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCr ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCr ? 'Credit' : 'Debit',
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _middle(TransactionEntry e) {
    final date = _formatDate(e.createdAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          e.reason,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.schedule, size: 14, color: Colors.black45),
            const SizedBox(width: 4),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        if (e.grabLeadId != null || e.transactionsId != null || e.studentGetCourseId != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              children: [
                if (e.grabLeadId != null)
                  _chip('Lead #${e.grabLeadId}', Colors.blue),
                if (e.transactionsId != null)
                  _chip('Txn #${e.transactionsId}', Colors.deepPurple),
                if (e.studentGetCourseId != null)
                  _chip('Course #${e.studentGetCourseId}', Colors.teal),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final mm = (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '${dt.month}';
      final dd = dt.day.toString().padLeft(2, '0');
      final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final am = dt.hour < 12 ? 'AM' : 'PM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$dd $mm ${dt.year}, $h12:$min $am';
    } catch (_) {
      return raw;
    }
  }

  Widget _chip(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(.25)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w700),
      ),
    );
  }
}
