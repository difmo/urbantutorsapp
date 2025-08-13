import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbantutorsapp/screens/admin/admin_tutor_page.dart';
import 'package:urbantutorsapp/screens/admin/amount_option_admin.dart';
import 'package:urbantutorsapp/screens/admin/notification_admin.dart';
import 'package:urbantutorsapp/screens/admin/parents_student_admin.dart';
import 'package:urbantutorsapp/screens/admin/transaction_admin.dart';
import 'package:urbantutorsapp/screens/admin/wallet_hits_admin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:urbantutorsapp/screens/admin/admit_profile.dart';
import 'package:urbantutorsapp/screens/admin/class_list_admin.dart';
import 'package:urbantutorsapp/screens/admin/feedback_admin.dart';
import 'package:urbantutorsapp/screens/admin/support_agent.dart';
import 'package:urbantutorsapp/screens/admin/term_conditions_admin.dart';
import '../theme/theme_constants.dart';

class AdminDrawer extends StatelessWidget {
  final Function(String label) onMenuTap;

  const AdminDrawer({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;

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
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              AssetImage('assets/icons/profile.jpg'),
                          backgroundColor: Colors.transparent,
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const AdmitProfile());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
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
                            'Nikhil Kumar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'nikhil@email.com',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Drawer Items
              _drawerItem(Icons.people_alt, 'Tutors',onTap: () {
                Get.to(() => AdminTutorPage());
              },),
              _drawerItem(
                Icons.person,
                'Parents / Students',
                onTap: () {
                  Get.to(() => ParentsStudentAdmin());
                },
              ),
              _drawerItem(
                Icons.balance,
                'Transaction',
                onTap: () {
                  Get.to(() => TransactionAdmin());
                },
              ),
              _drawerItem(
                Icons.account_balance_wallet,
                'Wallet Hits',
                onTap: () {
                  Get.to(() => WalletHitsPage());
                },
              ),
              _drawerItem(
                Icons.attach_money,
                'Amount Options',
                onTap: () {
                  Get.to(() => AmountOptionsScreen());
                },
              ),

              _drawerItem(
                Icons.notifications_active,
                'Send Notification',
                onTap: () {
                  showNotificationBottomSheet(context);
                },
              ),

              _drawerItem(
                Icons.notifications_none,
                'Notification History',
                onTap: () {
                  Get.to(() => const NotificationPage());
                },
              ),

              _drawerItem(
                Icons.language,
                'Connected Websites & Apps',
                onTap: () async {
                  await _launchURL('https://www.urbantutors.pro/');
                },
              ),

              _drawerItem(
                Icons.feedback,
                'Feedbacks',
                onTap: () {
                  Get.to(() => const FeedbackScreen());
                },
              ),
              _drawerItem(
                Icons.contact_phone,
                'Add Contact',
                onTap: () {
                  Get.to(() => const SupportAgentsScreen());
                },
              ),

              ExpansionTile(
                leading: const Icon(Icons.view_list),
                title: const Text(
                  'Dynamic Dropdown',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                children: [
                  _drawerItem(Icons.group, 'Class List', isSubItem: true,
                      onTap: () {
                    Get.to(() => const ClassListAdmin());
                  }),
                  _drawerItem(Icons.home, 'Board List', isSubItem: true),
                  _drawerItem(Icons.book, 'Subject List', isSubItem: true),
                ],
              ),

              _drawerItem(Icons.description, 'Terms & Conditions', onTap: () {
                Get.to(() => const TermsAndConditionsScreen());
              }),

              _drawerItem(Icons.share, 'Share', onTap: () {
                Share.share(
                  'Check out this amazing app: https://play.google.com/store/apps/details?id=com.urbantutors.app',
                );
              }),

              _drawerItem(Icons.logout, 'Logout', color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
      throw 'Could not launch $url';
    }
  }

  Widget _drawerItem(
    IconData icon,
    String label, {
    Color? color,
    bool isActive = false,
    bool isSubItem = false,
    VoidCallback? onTap,
  }) {
    final Color background =
        isActive ? AppColors.primaryColor.withOpacity(0.08) : Colors.white;
    final Color iconColor = color ?? Colors.grey.shade800;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSubItem ? 32 : 12,
        vertical: 4,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor, size: isSubItem ? 20 : null),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap ?? () => onMenuTap(label),
        ),
      ),
    );
  }
}

// 🔻 Notification Bottom Sheet Function
void showNotificationBottomSheet(BuildContext context) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final RxString selectedRole = 'Teacher'.obs;
  final RxString selectedState = 'All'.obs;

  final List<String> roles = ['Teacher', 'Student'];
  final List<String> states = [
    'All',
    'Delhi',
    'Maharashtra',
    'UP',
    'Karnataka'
  ];

  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 50,
          ),
          child: Wrap(
            spacing: 23,
            children: [
              const Center(
                child: Text(
                  'Send Notification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Role Dropdown
              Obx(() => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRole.value,
                    items: roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedRole.value = value;
                    },
                  )),

              SizedBox(
                height: 16,
              ),
              // State Dropdown
              Obx(() => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select State',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedState.value,
                    items: states.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedState.value = value;
                    },
                  )),
              const SizedBox(height: 12),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  final title = titleController.text.trim();
                  final message = messageController.text.trim();

                  if (title.isNotEmpty && message.isNotEmpty) {
                    Navigator.pop(context);
                    Get.snackbar(
                      'Success',
                      'Notification sent!',
                      backgroundColor: Colors.green.shade100,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    // TODO: Add your API call here
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter both title and message',
                      backgroundColor: Colors.red.shade100,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: const Text('Send Notification'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}
