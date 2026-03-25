import 'package:flutter/material.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../core/constants.dart';



class HIVPreventionPage extends StatelessWidget {
  final String ageRange;
  const HIVPreventionPage({super.key, required this.ageRange});

  @override
  Widget build(BuildContext context) {
    final isChild = ageRange == '10-14';
    final isTeen = ageRange == '15-19';
    final isAdult = ageRange == '20-24';

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: AppBottomNav(
        ageRange: ageRange,
        currentIndex: -1,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TopHeader(showBack: true),
            const SizedBox(height: 20),

            if (isChild) ..._childPrevention(),
            if (isTeen) ..._teenPrevention(),
            if (isAdult) ..._adultPrevention(),
          ],
        ),
      ),
    );
  }

  // ---------- AGE 10–14 ----------
  List<Widget> _childPrevention() => [
        const _PreventTile(
          image: "assets/images/no-sharb10.png",
          title: "Do Not Share Sharp Objects",
          text:
              "Never touch or share sharb objects. "
              "Ask an adult if you see needles or broken glass.",
        ),
        const _PreventTile(
          image: "assets/images/counsel.png",
          title: "Tell a Trusted Adult",
          text:
              "If you feel unsafe or confused, talk to a parent, teacher, or nurse.",
        ),
        const _PreventTile(
          image: "assets/images/clincb.png",
          title: "Visit Doctors When Sick",
          text:
              "Doctors help keep people healthy and prevent sickness.",
        ),
      ];

  // ---------- AGE 15–19 ----------
  List<Widget> _teenPrevention() => [
        const _PreventTile(
          image: "assets/images/condom.png",
          title: "Practice Safe Sex",
          text:
              "Using protection correctly reduces HIV risk. "
              "Respect consent and communicate clearly.",
        ),
        const _PreventTile(
          image: "assets/images/test.png",
          title: "Get Tested",
          text:
              "Regular HIV testing helps protect you and your partner.",
        ),
        const _PreventTile(
          image: "assets/images/clinic.png",
          title: "Visit Health Clinics",
          text:
              "Clinics provide counseling, testing, and accurate health information.",
        ),
      ];

  // ---------- AGE 20–24 ----------
  List<Widget> _adultPrevention() => [
        const _PreventTile(
          image: "assets/images/condom.png",
          title: "Consistent Protection",
          text:
              "Use condoms correctly every time to reduce HIV and STI transmission.",
        ),
        const _PreventTile(
          image: "assets/images/prep.png",
          title: "PrEP & ART",
          text:
              "Pre-Exposure Prophylaxis (PrEP) prevents HIV. "
              "ART helps people with HIV live healthy lives.",
        ),
        const _PreventTile(
          image: "assets/images/testing.png",
          title: "Regular HIV Testing",
          text:
              "Routine testing allows early treatment and prevents transmission.",
        ),
        const _PreventTile(
          image: "assets/images/doctor.png",
          title: "Professional Health Advice",
          text:
              "Consult healthcare professionals for accurate information and treatment.",
        ),
      ];
}

class _PreventTile extends StatelessWidget {
  final String image;
  final String title;
  final String text;

  const _PreventTile({
    required this.image,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // SAME AS CAUSE ✔
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Image.asset(image, height: 100),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimary, // SAME COLOR ✔
            ),
          ),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
