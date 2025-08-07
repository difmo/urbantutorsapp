import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/admin/admit_profile.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage('assets/icons/profile.jpg'),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
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
          
              // Drawer Items from Uploaded Image
              _drawerItem(Icons.people_alt, 'Tutors'),
              _drawerItem(Icons.person, 'Parents / Students'),
              _drawerItem(Icons.balance, 'Transaction'),
              _drawerItem(Icons.account_balance_wallet, 'Wallet Hits'),
              _drawerItem(Icons.attach_money, 'Amount Options'),
              _drawerItem(Icons.notifications_active, 'Send Notification'),
              _drawerItem(Icons.notifications_none, 'Notification History'),
              _drawerItem(Icons.language, 'Connected Websites & Apps'),
              _drawerItem(Icons.feedback, 'Feedbacks'),
              _drawerItem(Icons.contact_phone, 'Add Contact'),
          
              // Expandable Dynamic Dropdown section
              ExpansionTile(
                leading: const Icon(Icons.view_list),
                title: const Text(
                  'Dynamic Dropdown',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                children: [
                  _drawerItem(Icons.group, 'Class List', isSubItem: true),
                  _drawerItem(Icons.home, 'Board List', isSubItem: true),
                  _drawerItem(Icons.book, 'Subject List', isSubItem: true),
                ],
              ),
          
              _drawerItem(Icons.description, 'Terms & Conditions'),
              _drawerItem(Icons.share, 'Share'),
              _drawerItem(Icons.logout, 'Logout', color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  // Updated drawer item method with optional sub-item styling
  Widget _drawerItem(IconData icon, String label,
      {Color? color, bool isActive = false, bool isSubItem = false}) {
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
          onTap: () => onMenuTap(label),
        ),
      ),
    );
  }
}
