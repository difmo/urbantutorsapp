import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/theme_constants.dart';

class CustomTeacherNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomTeacherNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        onTap: onTap,
        items: [
          _buildItem(FontAwesomeIcons.noteSticky, 'Notes', 0, currentIndex),
          _buildItem(FontAwesomeIcons.userTie, 'Profile', 1, currentIndex),
          _buildItem(FontAwesomeIcons.bookOpenReader, 'Courses', 2, currentIndex),
          _buildItem(FontAwesomeIcons.comments, 'Chats', 3, currentIndex),
          _buildItem(FontAwesomeIcons.circleQuestion, 'Support', 4, currentIndex),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
      IconData icon, String label, int index, int current) {
    final bool isActive = index == current;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryColor.withOpacity(0.12)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              icon,
              size: 22,
              color: isActive ? AppColors.primaryColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3.5,
            width: isActive ? 22 : 0,
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.accentColor])
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}
