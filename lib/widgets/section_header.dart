import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
