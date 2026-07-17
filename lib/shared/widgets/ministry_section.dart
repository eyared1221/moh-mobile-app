import 'package:flutter/material.dart';
import '../../core/constants.dart';

class MinistrySection extends StatelessWidget {
  const MinistrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        // Deep Slate for Dark Mode, very light blue for Light Mode
        color: isDark ? const Color(0xFF1E293B) : kPrimarySoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : kPrimaryStroke,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // The official logo
          Image.asset(
            "assets/images/logo.png",
            height: 90,
          ),
          const SizedBox(height: 20),

          Text(
            "ሚኒስቴሪ - ጤና",
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF10304B),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "Official Service of the Ministry of Health",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF47A6DC) : kPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "Wise Youth is developed and managed by the Ethiopian Ministry of Health to provide safe, accurate, and youth-friendly information. "
            "Our mission is to empower young people (10–24) with trusted knowledge, privacy, and direct access to essential health services.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
              fontStyle: FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
