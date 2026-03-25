import 'package:flutter/material.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      const _FaqItem(
        question: "Do I need an account to use the app?",
        answer:
            "You can browse general health information and FAQs as a guest. "
            "Create an account to access full content, personalized tools, and support services.",
      ),
      const _FaqItem(
        question: "What can guests see?",
        answer:
            "Guest access is limited to basic health information and FAQs. "
            "Interactive features such as risk assessment and community chat require an account.",
      ),
      const _FaqItem(
        question: "Is my data private?",
        answer:
            "Yes. We collect only what is needed to provide services, and your information is handled securely.",
      ),
      const _FaqItem(
        question: "How do I get full access?",
        answer:
            "Tap Create Account or Sign In to unlock personalized guidance, risk assessment, and support options.",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161D2C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
                  iconColor: isDark ? Colors.white70 : Colors.black54,
                  title: Text(
                    item.question,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Text(
                        item.answer,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
