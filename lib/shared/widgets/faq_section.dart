import 'package:flutter/material.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      const _FaqItem(
        question: "What can I do in this app?",
        answer:
            "You can learn about HIV, STIs, hepatitis, sexual and reproductive health, GBV, and substance use. "
            "You can also take a risk check, find nearby care, and connect with support.",
      ),
      const _FaqItem(
        question: "Can I use the app without signing in?",
        answer:
            "Yes. As a guest, you can read general health information and FAQs. "
            "Sign in to unlock the full experience, including risk assessment, reminders, and more support options.",
      ),
      const _FaqItem(
        question: "What is the risk assessment?",
        answer:
            "It is a short check-in that asks about situations that may affect your health. "
            "It does not label you or replace a clinic visit, but it can guide you toward safer next steps.",
      ),
      const _FaqItem(
        question: "How do I find help near me?",
        answer:
            "Use the care or service section to view nearby clinics and health services. "
            "If you allow location access, the app can show places that are closer to you.",
      ),
      const _FaqItem(
        question: "Can I talk to someone for support?",
        answer:
            "Yes. The app can help you find peer mentors and support contacts. "
            "If you need guidance, you can use those options to reach someone safe and helpful.",
      ),
      const _FaqItem(
        question: "Will the app keep reminding me?",
        answer:
            "It can send reminders about things like learning updates or check-ins. "
            "You can control those reminders in your notification settings.",
      ),
      const _FaqItem(
        question: "Is my information private?",
        answer:
            "Your information should be handled carefully and used only for the support the app provides. "
            "You should not need to share more than what is necessary to use its features.",
      ),
    ];

    return Column(
      children: [
        ...items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161D2C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
                iconColor: isDark ? Colors.white70 : Colors.black54,
                title: Text(
                  item.question,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: Text(
                      item.answer,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
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
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
