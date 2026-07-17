import 'package:flutter/material.dart';

class WhyYegnaSection extends StatelessWidget {
  const WhyYegnaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF005C8F);

    final List<Map<String, dynamic>> items = [
      {"icon": Icons.menu_book, "text": "Interactive Learning Journey"},
      {"icon": Icons.payments_outlined, "text": "Earn Money by Using the App"},
      {"icon": Icons.groups_outlined, "text": "Youth Community Forum"},
      {"icon": Icons.chat_bubble, "text": "Chat with Experts"},
      {"icon": Icons.location_on, "text": "Nearby Clinics"},
      {"icon": Icons.smart_toy, "text": "Chatbot Form"},
      {"icon": Icons.rocket_launch, "text": "Advance Wellness Boosters"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Why Young People Love Wise Youth",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF47A6DC) : const Color(0xFF084C8C),
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                // Flat design (no shadow) to show it's not a button
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF7FBFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFEBF4FB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item["icon"] as IconData,
                    size: 20,
                    color: primaryBlue,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item["text"] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}