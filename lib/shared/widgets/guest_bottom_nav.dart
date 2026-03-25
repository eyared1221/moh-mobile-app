import 'package:flutter/material.dart';
import 'package:yegna_health/features/auth/presentation/signin_screen.dart';

class GuestBottomNav extends StatelessWidget {
  final int currentIndex;

  const GuestBottomNav({super.key, this.currentIndex = 2});

  void _showSignInPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        const primaryBlue = Color(0xFF005C8F);

        return Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161D2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                "Sign in to get more features",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Sign in to unlock risk assessment, support services, and your profile.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
                  },
                  child: const Text("SIGN IN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF005C8F);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _GuestNavItem(
              icon: Icons.home_rounded,
              label: "Home",
              active: currentIndex == 0,
              onTap: () => _showSignInPrompt(context),
            ),
            _GuestNavItem(
              icon: Icons.menu_book_rounded,
              label: "Learn",
              active: currentIndex == 1,
              onTap: () => _showSignInPrompt(context),
            ),
            _GuestCenterItem(
              label: "Guest",
              active: currentIndex == 2,
              onTap: () {},
              color: primaryBlue,
            ),
            _GuestNavItem(
              icon: Icons.location_on_rounded,
              label: "Clinic",
              active: currentIndex == 3,
              onTap: () => _showSignInPrompt(context),
            ),
            _GuestNavItem(
              icon: Icons.person_rounded,
              label: "Profile",
              active: currentIndex == 4,
              onTap: () => _showSignInPrompt(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _GuestNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryBlue = Color(0xFF005C8F);
    final color = active ? primaryBlue : (isDark ? Colors.blueGrey[300] : Colors.blueGrey[500]);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: primaryBlue.withOpacity(0.2),
      highlightColor: primaryBlue.withOpacity(0.12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? primaryBlue.withOpacity(isDark ? 0.18 : 0.12) : Colors.transparent,
          border: Border.all(
            color: active ? primaryBlue : Colors.transparent,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestCenterItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;

  const _GuestCenterItem({
    required this.label,
    required this.active,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Transform.translate(
      offset: const Offset(0, -12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.public_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
