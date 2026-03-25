import 'package:flutter/material.dart';

class SixCardsSection extends StatelessWidget {
  const SixCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Actual data list - do not leave this as [...]
    final List<Map<String, String>> items = [
      {
        "title": "What is HIV?",
        "desc": "HIV attacks the immune system, making it harder for the body to fight infections. Early testing and treatment help people live healthy lives.",
        "image": "assets/images/Aidsbbb.png"
      },
      {
        "title": "What are STDs?",
        "desc": "STDs like chlamydia and syphilis spread through sexual contact. Using condoms and getting tested regularly helps prevent issues.",
        "image": "assets/images/stdb.png"
      },
      {
        "title": "What is GBV?",
        "desc": "Gender-Based Violence includes physical, emotional, or sexual harm caused due to someone’s gender. Survivors need support and safety.",
        "image": "assets/images/GBVB.png"
      },
      {
        "title": "What is Hepatitis?",
        "desc": "Hepatitis causes inflammation of the liver. Vaccines, hygiene, and safe practices prevent infection. Early detection improves outcomes.",
        "image": "assets/images/HBTB.png"
      },
      {
        "title": "What is SRH?",
        "desc": "Sexual and Reproductive Health helps young people make informed choices about sex, contraception, and their bodies.",
        "image": "assets/images/momb.png"
      },
      {
        "title": "Drug Use & Effects",
        "desc": "Drug use affects the brain, relationships, and future goals. Some drugs cause addiction. Early help prevents long-term harm.",
        "image": "assets/images/smokingb.png"
      },
    ];

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final item = items[index];

          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // BACKGROUND IMAGE
                  Image.asset(
                    item["image"]!,
                    fit: BoxFit.cover,
                  ),

                  // DARK OVERLAY FOR READABILITY
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),

                  // FLOATING BOX
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // THE DARK MODE FIX:
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: isDark ? Border.all(color: Colors.white10) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item["title"]!,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item["desc"]!,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[850],
                              fontSize: 12.5,
                              height: 1.40,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
