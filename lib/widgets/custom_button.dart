import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final IconData? icon;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primary = color ?? Theme.of(context).primaryColor;

    final style = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: primary, width: 1.4),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );

    final btnChild = icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(onPressed: onPressed, style: style, child: btnChild)
          : OutlinedButton(onPressed: onPressed, style: style, child: btnChild),
    );
  }
}
