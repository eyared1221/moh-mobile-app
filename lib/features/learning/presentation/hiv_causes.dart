import 'package:flutter/material.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../core/constants.dart';



class HIVCausesPage extends StatelessWidget {
  final String ageRange;
  const HIVCausesPage({super.key, required this.ageRange});

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

            if (isChild) ..._childCauses(),
            if (isTeen) ..._teenCauses(),
            if (isAdult) ..._adultCauses(),
          ],
        ),
      ),
    );
  }

  // ---------- AGE 10–14 ----------
  List<Widget> _childCauses() => [
        const _CauseTile(
          image: "assets/images/no-sharb10.png",
          title: "Sharp Objects",
          text:
              "HIV can spread if sharp objects like needles or razors are shared. "
              "Never touch sharp things. Tell a trusted adult if you see them.",
        ),
        const _CauseTile(
          image: "assets/images/contact-blood10.png",
          title: "Blood Contact",
          text:
              "HIV can spread through blood. Do not touch blood. "
              "Ask an adult for help if someone is bleeding.",
        ),
        const _CauseTile(
          image: "assets/images/mom10.png",
          title: "From Mother to Baby",
          text:
              "A baby can get HIV from their mother if she is sick. "
              "Doctors help mothers protect their babies.",
        ),
      ];

  // ---------- AGE 15–19 ----------
  List<Widget> _teenCauses() => [
        const _CauseTile(
          image: "assets/images/cartoon-copleb.jpg",
          title: "Unprotected Sexual Contact",
          text:
              "HIV can spread through unprotected sexual contact. "
              "Using protection and knowing your partner’s status reduces risk.",
        ),
        const _CauseTile(
          image: "assets/images/nosharpb.png",
          title: "Sharing Sharp Objects",
          text:
              "Sharing needles, razors, or sharp tools can transmit HIV. "
              "Always use clean and personal items.",
        ),
        const _CauseTile(
          image: "assets/images/blood.png",
          title: "Blood Contact",
          text:
              "Contact with infected blood through open wounds or accidents can spread HIV.",
        ),
        const _CauseTile(
          image: "assets/images/mom14b.png",
          title: "Mother to Child",
          text:
              "HIV can pass from mother to child during pregnancy, birth, or breastfeeding "
              "without proper medical care.",
        ),
      ];

  // ---------- AGE 20–24 ----------
  List<Widget> _adultCauses() => [
        const _CauseTile(
          image: "assets/images/adult_sex.png",
          title: "Unprotected Sexual Activity",
          text:
              "HIV is most commonly transmitted through unprotected sexual activity. "
              "Multiple partners and lack of testing increase risk significantly.",
        ),
        const _CauseTile(
          image: "assets/images/needle.png",
          title: "Injecting Drug Use",
          text:
              "Sharing needles or injecting equipment is a high-risk behavior for HIV transmission.",
        ),
        const _CauseTile(
          image: "assets/images/blood_test.png",
          title: "Unsafe Blood Exposure",
          text:
              "Blood transfusions or medical procedures without proper screening "
              "can transmit HIV, though this is rare with modern healthcare.",
        ),
        const _CauseTile(
          image: "assets/images/mother_child.png",
          title: "Mother-to-Child Transmission",
          text:
              "Without treatment, HIV can be transmitted during pregnancy, delivery, "
              "or breastfeeding. ART greatly reduces this risk.",
        ),
      ];
}

class _CauseTile extends StatelessWidget {
  final String image;
  final String title;
  final String text;

  const _CauseTile({
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
        color: Colors.white,
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
              color: kPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
