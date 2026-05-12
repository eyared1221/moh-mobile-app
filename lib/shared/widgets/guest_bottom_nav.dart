import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestBottomNav extends StatefulWidget {
  final int currentIndex;
  final String? ageRange;
  final String? userName;
  final bool? isLoggedIn;

  const GuestBottomNav({
    super.key,
    this.currentIndex = 2,
    this.ageRange,
    this.userName,
    this.isLoggedIn,
  });

  @override
  State<GuestBottomNav> createState() => _GuestBottomNavState();
}

class _GuestBottomNavState extends State<GuestBottomNav> {
  bool _isLoggedIn = false;
  String _ageRange = '10-14';
  String _userName = 'Yegna User';

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn ?? false;
    _ageRange = widget.ageRange ?? _ageRange;
    _userName = widget.userName ?? _userName;
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _isLoggedIn = widget.isLoggedIn ?? (prefs.getBool('isLoggedIn') ?? false);
      _ageRange = widget.ageRange ?? (prefs.getString('userAge') ?? _ageRange);
      _userName = widget.userName ?? (prefs.getString('userName') ?? _userName);
    });
  }

  void _navigateTo(String route, {Map<String, dynamic>? arguments}) {
    Navigator.pushReplacementNamed(
      context,
      route,
      arguments: arguments,
    );
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;

    if (index == 2) {
      if (_isLoggedIn) {
        _navigateTo(
          '/mentor',
          arguments: {'ageRange': _ageRange, 'userName': _userName},
        );
      } else {
        _showSignInPrompt(context);
      }
      return;
    }

    if (!_isLoggedIn) {
      _showSignInPrompt(context);
      return;
    }

    switch (index) {
      case 0:
        _navigateTo(
          '/home',
          arguments: {'ageRange': _ageRange, 'userName': _userName},
        );
        break;
      case 1:
        _navigateTo(
          '/learning',
          arguments: {'ageRange': _ageRange, 'userName': _userName},
        );
        break;
      case 3:
        _navigateTo(
          '/clinic',
          arguments: {'ageRange': _ageRange, 'userName': _userName},
        );
        break;
      case 4:
        _navigateTo(
          '/profile',
          arguments: {'ageRange': _ageRange, 'userName': _userName},
        );
        break;
    }
  }

  void _showSignInPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          decoration: BoxDecoration(
            color: theme.cardColor,
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
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                'Sign in for full access',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to use risk assessment, access learning modules, get health services, and connect with peer mentors.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, '/signin');
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.28 : 0.08),
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
              label: 'Home',
              active: widget.currentIndex == 0,
              onTap: () => _handleTap(0),
              activeColor: colorScheme.primary,
            ),
            _GuestNavItem(
              icon: Icons.menu_book_rounded,
              label: 'Learn',
              active: widget.currentIndex == 1,
              onTap: () => _handleTap(1),
              activeColor: colorScheme.primary,
            ),
            _GuestCenterItem(
              label: 'Mentor',
              active: widget.currentIndex == 2,
              onTap: () => _handleTap(2),
              color: colorScheme.primary,
              icon: Icons.people_alt_rounded,
            ),
            _GuestNavItem(
              icon: Icons.location_on_rounded,
              label: 'Clinic',
              active: widget.currentIndex == 3,
              onTap: () => _handleTap(3),
              activeColor: colorScheme.primary,
            ),
            _GuestNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              active: widget.currentIndex == 4,
              onTap: () => _handleTap(4),
              activeColor: colorScheme.primary,
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
  final Color activeColor;

  const _GuestNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = active ? activeColor : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: activeColor.withOpacity(0.2),
      highlightColor: activeColor.withOpacity(0.12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
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
  final IconData icon;

  const _GuestCenterItem({
    required this.label,
    required this.active,
    required this.onTap,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: colorScheme.onPrimary, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
