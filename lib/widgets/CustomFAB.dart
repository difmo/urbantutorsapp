import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primary, accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: RawMaterialButton(
        onPressed: onPressed,
        shape: const CircleBorder(),
        elevation: 6,
        fillColor: Colors.transparent,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
