import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/feedback_student.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/notification_student.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/student_profile.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/term_condition_student.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import '../theme/theme_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class StudentDrawer extends StatefulWidget {
  final Function(String label) onMenuTap;

  const StudentDrawer({super.key, required this.onMenuTap});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  String selectedLabel = 'Term and Conditions'; // Default selected menu

  void handleTap(String label, {VoidCallback? onTap}) {
    setState(() {
      selectedLabel = label;
    });

    // ✅ Close the drawer first
    Navigator.pop(context);

    // ✅ Perform the action (navigation, share, etc.)
    if (onTap != null) onTap();
  }

  Widget _drawerItem(
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final bool isSelected = selectedLabel == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: color ?? Colors.grey.shade800),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => handleTap(label, onTap: onTap),
        ),
      ),
    );
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
              // Profile Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: const Text(
                            "S",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const StudentProfileScreen());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
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
                                size: 16,
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
                            'Shaurabh Kumar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'shaurabh@email.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Menu Items
              _drawerItem(
                Icons.description,
                'Term and Conditions',
                onTap: () {
                  Get.to(() => const TermConditionStudent());
                },
              ),
              _drawerItem(
                Icons.language,
                'Connected Websites & Apps',
                onTap: () async {
                  final Uri url = Uri.parse('https://www.urbantutors.pro/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              _drawerItem(
                Icons.feedback,
                'Feedback',
                onTap: () {
                  Get.to(() => FeedbackStudent());
                },
              ),
              _drawerItem(
                Icons.notifications,
                'Notifications',
                onTap: () {
                  Get.to(() => NotificationStudent());
                },
              ),
              _drawerItem(
                Icons.share,
                'Share app',
                onTap: () {
                  _shareApp();
                },
              ),
              _drawerItem(
                Icons.delete_forever,
                'Delete Account',
                onTap: () {
                  _showDeleteDialog(context);
                },
              ),
              _drawerItem(
                Icons.logout,
                'Logout',
                color: Colors.red,
                onTap: () {
                  StorageService.clearTokenAndRole();
                  StorageService.clear();
                  Get.to(WelcomeScreen());
                  // Add logout logic here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
