import 'package:flutter/material.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../core/constants.dart';
import '../../../shared/data/hiv_content.dart';
import 'hiv_causes.dart';
import 'hiv_prevention.dart';

class HIVDescriptionPage extends StatelessWidget {
  final String ageRange;
  const HIVDescriptionPage({super.key, required this.ageRange});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic> getContent() {
      if (ageRange == '10-14') {
        return {
          "mainImg": "assets/images/hivb.jpeg",
          "introTitle": "Your Body's Shield",
          "introText": "HIV is a tiny bug that tries to sneak past your body's soldiers.",
          "moreInfo": HIVContent.childIntroLong,
          "aidsText": "AIDS is just a name for when the shield gets very tired. Medicine keeps the shield strong!",
          "causeImg": "assets/images/contact-blood10.png",
          "themeColor": Colors.blueAccent,
        };
      } else {
        return {
          "mainImg": "assets/images/hiv_adult.png",
          "introTitle": "Understanding HIV",
          "introText": "A manageable virus that affects how your body fights off germs.",
          "moreInfo": HIVContent.adultIntroLong,
          "aidsText": "AIDS is the advanced stage. Modern treatment (ART) usually prevents this entirely.",
          "causeImg": "assets/images/blood.png",
          "themeColor": kPrimary,
        };
      }
    }

    final data = getContent();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1220) : kBg,
      bottomNavigationBar: AppBottomNav(ageRange: ageRange, currentIndex: -1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TopHeader(showBack: true),
            
            // PICTORIAL ELEMENTS FOR KIDS
            if (ageRange == '10-14') _PictorialTip(isDark: isDark),

            // INTERACTIVE MAIN CARD
            _InteractiveInfoCard(
              title: data["introTitle"],
              shortText: data["introText"],
              longText: data["moreInfo"],
              image: data["mainImg"],
              isDark: isDark,
              color: data["themeColor"],
            ),

            

            const SectionTitle(title: "Learn More"),

            _NavCard(
              title: "What causes it?",
              image: data["causeImg"],
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HIVCausesPage(ageRange: ageRange))),
            ),

            _NavCard(
              title: "How to stay safe?",
              image: "assets/images/nosharpb15.png",
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HIVPreventionPage(ageRange: ageRange))),
            ),
          ],
        ),
      ),
    );
  }
}

// NEW PICTORIAL WIDGET FOR 10-14
class _PictorialTip extends StatelessWidget {
  final bool isDark;
  const _PictorialTip({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(isDark ? 0.1 : 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Text("💡", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Did you know? Doctors are like health superheroes!",
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// IMPROVED INTERACTIVE CARD
class _InteractiveInfoCard extends StatelessWidget {
  final String title, shortText, longText, image;
  final bool isDark;
  final Color color;

  const _InteractiveInfoCard({required this.title, required this.shortText, required this.longText, required this.image, required this.isDark, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: InfoCard(
        child: Column(
          children: [
            Image.asset(image, height: 120),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(shortText, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 15),
            
            // THE "TAP" INDICATOR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("Tap for Ministry details...", style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161D2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Official Health Guidance", style: TextStyle(color: color, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Expanded(child: SingleChildScrollView(child: Text(longText, style: const TextStyle(fontSize: 16, height: 1.6)))),
            ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: color), child: const Text("I Understand")),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title, image;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({required this.title, required this.image, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161D2C) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Image.asset(image, height: 50, width: 50),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}