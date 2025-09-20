// lib/screens/student/childs_screens/coins_student.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/models/coin_package.dart';
import 'package:urbantutorsapp/models/my_coins.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class Upgradescreen extends StatefulWidget {
  const Upgradescreen({super.key});

  @override
  State<Upgradescreen> createState() => _CoinsStudentScreenState();
}

class _CoinsStudentScreenState extends State<Upgradescreen> {
  late final CoinsController _c;

  // Safe number formatter
  num _numVal(dynamic v) {
    if (v is num) return v;
    if (v == null) return 0;
    return num.tryParse(v.toString()) ?? 0;
  }

  final PayCourseController _payCourseController =
      Get.find<PayCourseController>();

  static const blue = Color(0xFF4A90E2);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _currentIndex = 0;

  late final ProfileUpdateController _p; // ⬅️ NEW

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());

    // 👇 Schedule after first frame to avoid "setState during build" from Obx
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.refreshAll();
    });

    print("Loaded courses:");
    for (var course in _payCourseController.courses) {
      print(course.toJson());
    }

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    // Try to ensure profile is present
    _p.fetchProfileForStudent();
  }

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

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          final packs = _c.coins; // RxList<CoinPackage>
          final wallet = _c.myCoins.value; // nullable model
          final available = _numVal(wallet?.available).toStringAsFixed(0);
      
          if (_c.loadingCoins.value && _c.loadingMyCoins.value) {
            return const Center(child: CircularProgressIndicator());
          }
      
          return LayoutBuilder(
            builder: (context, cts) {
              final width = cts.maxWidth;
              final isWide = width >= 700;
      
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Kindly Upgrade Your Wallet : $available Coins Only /-',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
      
                    // ---------- Packs ----------
                    if (_c.loadingCoins.value)
                      const Center(child: CircularProgressIndicator())
                    else if (_c.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _c.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (packs.isEmpty)
                      const Center(child: Text('No coin packs available'))
                    else if (!isWide)
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap:
                            true, // so it can live inside another scroll view
                        physics:
                            const NeverScrollableScrollPhysics(), // parent scrolls
                        itemCount: packs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 🔹 two per row
                          crossAxisSpacing: 12, // gap between columns
                          mainAxisSpacing: 12, // gap between rows
                          childAspectRatio:
                              1.5, // tweak to fit your tile’s height
                        ),
                        itemBuilder: (_, i) {
                          final p = packs[i];
                          return LayoutBuilder(
                            builder: (ctx, cons) => _PackTile(
                              pack: p,
                              primary: primary,
                              accent: accent,
                              width:
                                  cons.maxWidth, // give the tile its real width
                              onTap: () => _showCheckout(context, p, primary),
                            ),
                          );
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          itemCount: packs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (width ~/ 260).clamp(2, 6),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 260 / 130,
                          ),
                          itemBuilder: (_, i) {
                            final p = packs[i];
                            return _PackTile(
                              pack: p,
                              primary: primary,
                              accent: accent,
                              width: double.infinity,
                              onTap: () => _showCheckout(context, p, primary),
                            );
                          },
                        ),
                      ),
      
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 6),
                          Text('Successful', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 16),
                          Icon(Icons.error, color: Colors.red, size: 20),
                          SizedBox(width: 6),
                          Text('Failed', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
      
                    // ---------- Transactions ----------
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Transactions :',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
      
                    if (_c.loadingMyCoins.value)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_c.myCoinsError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(_c.myCoinsError.value,
                            style: const TextStyle(color: Colors.red)),
                      )
                    else if (_c.txns.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text('No transactions available',
                              style: TextStyle(color: Colors.black54)),
                        ),
                      )
                    else
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _c.txns.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _TxnTile(tx: _c.txns[i]),
                      ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // ---------- Checkout (Razorpay/Quince) ----------
  void _showCheckout(BuildContext context, CoinPackage p, Color primary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final mq = MediaQuery.of(context);

        final base = p.baseAmount ?? p.effectiveAmount;
        final discount = p.hasPercentOffer
            ? base * (p.discountPercentage ?? 0) / 100
            : (p.flatOff ?? 0);
        final effective = (base - discount).clamp(0, double.infinity);
        final gst = effective * 0.12;
        final total = effective + gst;

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: mq.size.height * 0.85,
              maxWidth: mq.size.width * 0.95,
            ),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checkout',
                    style: TextStyle(
                        color: primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _row('Coins', '${p.coins}'),
                _row('Base Price', '₹${base.toStringAsFixed(2)}'),
                if (discount > 0)
                  _row('Discount', '- ₹${discount.toStringAsFixed(2)}'),
                _row('Subtotal', '₹${effective.toStringAsFixed(2)}'),
                _row('GST (12%)', '₹${gst.toStringAsFixed(2)}'),
                const Divider(height: 22),
                _row('Total Payable', '₹${total.toStringAsFixed(2)}',
                    bold: true),
                const SizedBox(height: 16),

                // Only the changing button area is reactive
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    final busy = _c.isCreatingOrder.value;
                    return Wrap(
                      spacing: 12,
                      children: [
                        ElevatedButton(
                          onPressed: busy
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _c.startRazorpayCheckout(context, p);
                                },
                          child:
                              Text(busy ? 'Processing…' : 'Pay with Razorpay'),
                        ),
                        // If you need Quince too, uncomment:
                        // ElevatedButton(
                        //   onPressed: busy
                        //       ? null
                        //       : () {
                        //           Navigator.pop(context);
                        //           _c.checkoutQuince(context, p);
                        //         },
                        //   child: const Text('Pay with Quince'),
                        // ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(a)),
            Text(
              b,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500),
            ),
          ],
        ),
      );
}

class _PackTile extends StatelessWidget {
  const _PackTile({
    required this.pack,
    required this.primary,
    required this.accent,
    required this.width,
    required this.onTap,
  });

  final CoinPackage pack;
  final Color primary;
  final Color accent;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasOffer =
        pack.hasPercentOffer || pack.flatOff > 0 || (pack.offers ?? 0) == 1;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasOffer)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pack.hasPercentOffer
                        ? '${pack.discountPercentage}% OFF'
                        : 'Save ₹${pack.flatOff.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.deepOrange),
                  ),
                ),
              Text(
                '${pack.coins} Coins @',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              Text(
                '₹${pack.effectiveAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primary,
                ),
              ),
              const SizedBox(height: 4),
              if ((pack.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  pack.description ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.tx});
  final CoinTxn tx;

  @override
  Widget build(BuildContext context) {
    final ok = tx.status == 1;
    final color = ok ? Colors.green : Colors.red;
    final label = ok ? 'Successful' : 'Failed';
    final date = tx.createdAt != null
        ? '${tx.createdAt!.toLocal()}'.split('.').first
        : '-';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.error, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${tx.finalAmount.toStringAsFixed(2)} • +${tx.coins.toStringAsFixed(0)} coins',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text('Order: ${tx.orderId ?? '-'}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(date,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.primary,
    required this.accent,
    required this.onCoinTap,
    required this.balance,
    required this.initial, // ⬅️ NEW
    required this.greeting, // ⬅️ NEW
    required this.name, // ⬅️ NEW
  });

  final Color primary;
  final Color accent;
  final VoidCallback onCoinTap;
  final String balance;

  final String initial;
  final String greeting;
  final String name;
  String _capFirst(String s) {
    final t = s.trim();
    if (t.isEmpty) return '';
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 8,
        ),
        // Avatar with gradient ring

        const SizedBox(width: 12),

        // Greeting + name (ellipsized)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Wallet",
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
                    // const Icon(Icons.monetization_on,
                    //     size: 16, color: Colors.white),
                    const SizedBox(width: 6),

                    Text(
                      '${balance == "0" ? "Upgrade" : "$balance coins"} ',
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
