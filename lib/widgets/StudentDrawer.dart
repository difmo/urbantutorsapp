import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/history_student.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/support_student.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/transactions_student.dart';
import 'package:urbantutorsapp/screens/student/mycourses_student.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/feedback_student.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/notification_student.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/student_profile_screen.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import '../theme/theme_constants.dart';

class StudentDrawer extends StatefulWidget {
  final Function(String label) onMenuTap;
  const StudentDrawer({super.key, required this.onMenuTap});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  String selectedLabel = 'Term and Conditions';
  final ProfileUpdateController _profile =
      Get.isRegistered<ProfileUpdateController>()
          ? Get.find<ProfileUpdateController>()
          : Get.put(ProfileUpdateController());

  @override
  void initState() {
    super.initState();
    if (_profile.studentprofileData.value == null) {
      _profile.fetchProfileForStudent();
    }
  }

  String _capFirst(String s) {
    final t = s.trim();
    if (t.isEmpty) return '';
    return t[0].toUpperCase() + t.substring(1);
  }

  void handleTap(String label, {VoidCallback? onTap}) {
    setState(() => selectedLabel = label);
    Navigator.pop(context); // close drawer first
    onTap?.call();
  }

  String _firstName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'Student';
    final parts = n.split(RegExp(r'\s+'));
    return parts.first;
  }

  Widget _drawerItem(
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final bool isSelected = selectedLabel == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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

  // Helpers
  String _str(dynamic v, {String fallback = ''}) {
    final s = (v?.toString() ?? '').trim();
    return s.isEmpty ? fallback : s;
  }

  String _initialFrom(String? name) {
    final s = (name ?? '').trim();
    if (s.isEmpty) return 'U';
    // simple & safe for Latin; adjust if you need complex scripts
    return s[0].toUpperCase();
  }

  Future<void> _openTerms() async {
    final Uri url = Uri.parse('https://urbantutors.pro/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Terms & Conditions')),
      );
    }
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
              Obx(() {
                final loading = _profile.isLoading.value &&
                    _profile.studentprofileData.value == null;
                final p = _profile.studentprofileData.value;

                if (loading) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2, color: AppColors.accentColor)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: 140,
                                color: Colors.grey.shade200,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 14,
                                width: 100,
                                color: Colors.grey.shade200,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final name = _str(p?.studentName, fallback: 'User');
                final mobile = _str(p?.mobile, fallback: '');
                final course = _str(p?.courseName, fallback: '');
                final profileId =
                    _str(p?.profileId, fallback: ''); // if present in model
                final displayName = _firstName(name);

                return Container(
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
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2, color: AppColors.primaryColor)),
                            child: (p?.profile_picture != null && p!.profile_picture!.isNotEmpty)
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage: () {
                                      final img = p.profile_picture!;
                                      if (img.startsWith('http')) {
                                        return NetworkImage(img);
                                      } else if (img.startsWith('data:')) {
                                        return MemoryImage(base64Decode(img.split(',').last));
                                      } else {
                                        return NetworkImage('https://urbantutors.pro/$img');
                                      }
                                    }() as ImageProvider,
                                  )
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundColor: primaryColor.withOpacity(0.12),
                                    child: Text(
                                      _initialFrom(name),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _capFirst(displayName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (profileId.isNotEmpty) ...[
                                  Flexible(
                                    child: Text(
                                      profileId,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ] else if (profileId.isNotEmpty) ...[
                                  const Icon(Icons.badge,
                                      size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      profileId,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              _drawerItem(
                Icons.description,
                'Profile',
                onTap: () => Get.to(() => StudentProfileScreen()),
              ),

              _drawerItem(
                Icons.feedback,
                'Feedback',
                onTap: () => Get.to(() => const FeedbackStudent()),
              ),
              _drawerItem(
                Icons.notifications,
                'Notifications',
                onTap: () => Get.to(() => const NotificationStudent()),
              ),
              _drawerItem(
                Icons.transcribe_sharp,
                'Transactions',
                onTap: () => Get.to(() => const TransactionsStudent()),
              ),

              _drawerItem(
                Icons.history,
                'My Courses',
                onTap: () => Get.to(() => const MycoursesStudent()),
              ),
              _drawerItem(
                Icons.history,
                'History',
                onTap: () => Get.to(() => const HistoryStudent()),
              ),

              _drawerItem(
                Icons.share,
                'Share app',
                onTap: _shareApp,
              ),
              // ===== Menu items =====
              _drawerItem(
                Icons.description,
                'Term and Conditions',
                onTap: () => {_openTerms()},
              ),

              _drawerItem(
                Icons.language,
                'Go to Website',
                onTap: () async {
                  final Uri url = Uri.parse('https://www.urbantutors.pro/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar('Error', 'Could not launch $url');
                  }
                },
              ),
              _drawerItem(
                Icons.notifications,
                'Get Support',
                onTap: () => Get.to(() => const SupportStudent()),
              ),
              // _drawerItem(
              //   Icons.delete_forever,
              //   'Delete Account',
              //   onTap: () => _showDeleteDialog(context),
              // ),
              _drawerItem(
                Icons.logout,
                'Logout',
                color: Colors.red,
                onTap: () async {
                  await StorageService.clearTokenAndRole();
                  await StorageService.clear();
                  Get.offAll(() => const WelcomeScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
