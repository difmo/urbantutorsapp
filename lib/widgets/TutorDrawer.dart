import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbantutorsapp/screens/tutor/Terms_conditions_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/aboutUs_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/feedback_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_profile.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_pyq_screen.dart';
import 'package:urbantutorsapp/screens/tutor/wallet_tutor_history.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme_constants.dart';

class TutorDrawer extends StatelessWidget {
  final Function(String label)? onMenuTap;
  final String activeLabel;

  const TutorDrawer({
    Key? key,
    this.onMenuTap,
    this.activeLabel = '',
  }) : super(key: key);

  Future<void> _launchRateUs() async {
    const url =
        'https://play.google.com/store/apps/details?id=pro.urbantutors.app&hl=en_IN';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open Play Store Link');
    }
  }

  void _shareApp() {
    const playStoreLink =
        'https://play.google.com/store/apps/details?id=pro.urbantutors.app&pcampaignid=web_share';
    Share.share('Check out Urban Tutors App: $playStoreLink');
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: const Text('Are you sure you want to delete your?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor),
                child: const Text('CONFIRM'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: primaryColor.withOpacity(0.15),
                          child: const Text(
                            "N",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Close drawer
                              Get.to(() => const TutorPYQScreen());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nikhil Kumar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'nikhil@email.com',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Drawer Items
              _drawerItem(
                Icons.person,
                'Profile',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => ProfileScreen());
                },
              ),
              _drawerItem(
                Icons.account_balance_wallet,
                'Wallet',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => TutorCoinsScreen());
                },
              ),
              _drawerItem(
                Icons.attach_money,
                'Wallet History',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => WalletTutorHistory());
                },
              ),
              _drawerItem(
                Icons.description,
                'Terms & Conditions',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => TermsConditionsTutor());
                },
              ),
              _drawerItem(
                Icons.language,
                'Connected Websites & Apps',
                onTap: () async {
                  Navigator.pop(context);
                  final url = Uri.parse('https://urbantutors.pro/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar('Error', 'Cound not oprn the Website');
                  }
                },
              ),
              _drawerItem(
                Icons.feedback,
                'Feedback',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => FeedbackTutor());
                },
              ),
              _drawerItem(Icons.star_rate, 'Rate us', onTap: () {
                Navigator.pop(context);
                _launchRateUs();
              }),
              _drawerItem(
                Icons.share,
                'Share app',
                onTap: () {
                  Navigator.pop(context);
                  _shareApp();
                },
              ),
              _drawerItem(
                Icons.info_outline,
                'About us',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => AboutusTutor());
                },
              ),
              _drawerItem(
                Icons.delete,
                'Delete Account',
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context);
                },
              ),
              _drawerItem(Icons.logout, 'Logout', color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final bool isActive = label == activeLabel;
    final Color background = isActive
        ? AppColors.primaryColor.withOpacity(0.08)
        : Colors.transparent;
    final Color iconColor = color ?? Colors.grey.shade800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap ??
              () {
                if (onMenuTap != null) {
                  onMenuTap!(label);
                }
              },
        ),
      ),
    );
  }
}
