import 'package:flutter/material.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';
import 'package:urbantutorsapp/widgets/StudentDrawer.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';

/// Drawer for screens shared by several roles: shows the menu that matches
/// the logged-in user's role.
class RoleDrawer extends StatelessWidget {
  const RoleDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: StorageService.getRoleId(),
      builder: (context, snap) {
        switch (snap.data) {
          case 2:
            return const Tutordrawer();
          case 5:
            return const Admindrawer();
          case 3:
            return const StudentDrawer();
          default:
            return const Drawer(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
