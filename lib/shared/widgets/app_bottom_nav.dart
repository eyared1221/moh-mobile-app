import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/services/presentation/clinic_page.dart';

class AppBottomNav extends StatefulWidget {
  final String ageRange;
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.ageRange,
    required this.currentIndex,
  });

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  String _userName = 'Yegna User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Yegna User';
    });
  }

  void _navigate(int index) {
    if (index == widget.currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = HomePage(ageRange: widget.ageRange, userName: _userName);
        break;
      case 1:
        page = ClinicPage(ageRange: widget.ageRange);
        break;
      case 3:
        page = ProfilePage(ageRange: widget.ageRange, userName: _userName);
        break;
      default:
        return;
    }

    // Using pushReplacement with a subtle fade transition for a professional feel
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0072C6);

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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              active: widget.currentIndex == 0,
              onTap: () => _navigate(0),
            ),
            _NavItem(
              icon: Icons.location_on_rounded,
              label: 'Clinic',
              active: widget.currentIndex == 1,
              onTap: () => _navigate(1),
            ),
            _NavItem(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              active: widget.currentIndex == 2,
              onTap: () {}, // Future Version
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              active: widget.currentIndex == 3,
              onTap: () => _navigate(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0072C6);
    final activeColor = active ? primaryColor : (isDark ? Colors.grey[500] : Colors.grey[600]);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Active background "Pill" highlight
          color: active 
              ? primaryColor.withOpacity(isDark ? 0.15 : 0.08) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: activeColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
