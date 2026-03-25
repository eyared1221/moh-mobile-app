import 'package:flutter/material.dart';
import '../../../shared/widgets/blue_card.dart';
import '../../../shared/widgets/six_cards_section.dart';
import '../../../shared/widgets/ministry_section.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/faq_section.dart';
import '../../../shared/widgets/guest_bottom_nav.dart';
import '../../auth/presentation/signin_screen.dart';
import '../../auth/presentation/signup_screen.dart';

class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF005C8F);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlueCard(
              onSignUp: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: SectionTitle(title: "General Health Information"),
            ),
            const SixCardsSection(),
            const SizedBox(height: 18),
            _SignInCtaCard(
              onSignIn: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: SectionTitle(title: "FAQs"),
            ),
            const FaqSection(),
            const SizedBox(height: 28),
            const MinistrySection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                  child: const Text("GET STARTED", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GuestBottomNav(),
    );
  }
}

class _SignInCtaCard extends StatelessWidget {
  final VoidCallback onSignIn;

  const _SignInCtaCard({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF005C8F);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161D2C) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Unlock Full Access",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sign in to access risk assessment, community support, and personalized guidance.",
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("SIGN IN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
