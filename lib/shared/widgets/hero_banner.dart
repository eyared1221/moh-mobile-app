import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String age;

  const HeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // Increased Vertical Padding (60) to push the height from top to bottom
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      width: double.infinity,
      // Using Center ensures the text stays balanced in the larger box
      alignment: Alignment.centerLeft, 
      child: Text(
        title,
        style: TextStyle(
          fontSize: 28, // Slightly larger font for the taller box
          height: 1.2,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}