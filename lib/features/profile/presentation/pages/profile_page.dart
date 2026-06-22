import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../auth/presentation/signin_screen.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../domain/entities/profile_user_entity.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_page.dart';
import 'language_page.dart';
import 'notifications_page.dart';
import 'privacy_security_page.dart';
import 'support_center_page.dart';
import 'theme_settings_page.dart';

class ProfilePage extends StatefulWidget {
  final String age;
  final String? userName;
  final String? language;

  const ProfilePage({
    super.key,
    required this.age,
    this.userName,
    this.language,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController.standard();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  late ProfileUserEntity _profile;

  @override
  void initState() {
    super.initState();
    _profile = ProfileUserEntity(
      fullName: widget.userName ?? 'Alex Johnston',
      age: int.tryParse(widget.age) ?? 24,
      email: '',
      phone: '',
      language: widget.language ?? 'English',
    );
    _bootstrapProfile();
  }

  int get _fallbackAge => int.tryParse(widget.age) ?? 24;

  Future<void> _bootstrapProfile() async {
    final isLoggedInFuture = _controller.isLoggedIn();
    final cachedProfileFuture = _controller.loadCachedProfile(
      fallbackAge: _fallbackAge,
      fallbackName: widget.userName,
    );

    final isLoggedIn = await isLoggedInFuture;
    final cachedProfile = await cachedProfileFuture;

    if (!mounted) return;

    if (cachedProfile != null) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _profile = cachedProfile;
        _isLoading = false;
      });
    } else if (!isLoggedIn) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      return;
    }

    if (!isLoggedIn) {
      return;
    }

    final refreshedProfile = await _controller.loadProfile(
      fallbackAge: _fallbackAge,
      fallbackName: widget.userName,
    );

    if (!mounted) return;

    setState(() {
      _isLoggedIn = true;
      _profile = refreshedProfile;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile(ProfileUserEntity profile) async {
    try {
      final savedProfile = await _controller.saveProfile(profile);
      if (!mounted) return;
      setState(() => _profile = savedProfile);
      _showProfileUpdatedNotice();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showProfileUpdatedNotice() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: const Duration(seconds: 3),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile updated',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your changes were saved successfully.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Future<void> _openEditProfilePage() async {
    final updated = await Navigator.push<ProfileUserEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(profile: _profile),
      ),
    );

    if (updated != null) {
      await _saveProfile(updated);
    }
  }

  // Keeps hot-reload from calling a deleted method while the app state updates.
  Future<void> _openEditProfileDialog() {
    return _openEditProfilePage();
  }

  // Compatibility shim for stale hot-reload closures from the old edit dialog.
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.6,
          ),
        ),
      ),
    );
  }

  Future<void> _openLanguagePage() async {
    final updated = await Navigator.push<ProfileUserEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => LanguagePage(profile: _profile),
      ),
    );
    if (updated != null) {
      setState(() => _profile = updated);
    } else {
      await _bootstrapProfile();
    }
  }

  Future<void> _openThemeSettingsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<bool> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _logout() async {
    await _controller.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline_rounded, size: 54, color: colorScheme.primary),
                const SizedBox(height: 10),
                Text(
                  'Sign in to view your profile',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
  centerTitle: true,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  backgroundColor: theme.scaffoldBackgroundColor,
  actions: [
    PopupMenuButton<String>(
      offset: const Offset(0, 50),

      elevation: 4,

      color: theme.cardColor,

      surfaceTintColor: Colors.transparent,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      onSelected: (value) async {
        if (value == 'logout') {
          final ok = await _confirmLogout();

          if (!ok) return;

          await _logout();
        }
      },

      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'logout',

          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: colorScheme.primary,
                size: 22,
              ),

              const SizedBox(width: 12),

              Text(
                'Log Out',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],

      child: Padding(
        padding: const EdgeInsets.only(
          right: 14,
          left: 4,
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: colorScheme.onSurface,
          size: 27,
        ),
      ),
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileHeader(context),
            const SizedBox(height: 18),
            _primaryActionsSection(context),
            const SizedBox(height: 24),
            Text(
              'ACCOUNT SETTINGS',
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 13,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _settingsSection(context),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Version 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        age: _profile.age.toString(),
        currentIndex: 4,
        userName: _profile.fullName,
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.onSurface.withOpacity(0.18),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 84,
              color: colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _profile.fullName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

          
Widget _actionTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color accent,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ FIX
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 14),

          /// 🔥 FIX: wrap with Expanded + give proper height
          Expanded(
            child: SizedBox(
              height: 60, // ✅ FORCE HEIGHT (critical fix)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // ✅ center text
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
        ],
      ),
    ),
  );
}

  Widget _primaryActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _primaryActionRow(
            context,
            icon: Icons.person_2_outlined,
            title: 'Edit Profile',
            subtitle: 'Identity • Age',
            accent: colorScheme.primary,
            onTap: _openEditProfilePage,
          ),
          _settingsDivider(colorScheme),
          _primaryActionRow(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Preferences • Alerts',
            accent: colorScheme.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _primaryActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _settingsRow(
            context,
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            subtitle: 'Password • Privacy • Security',
            trailingText: null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivacySecurityPage(
                    language: widget.language,
                    email: _profile.email,
                  ),
                ),
              );
            },
          ),
          _settingsDivider(colorScheme),
          _settingsRow(
            context,
            icon: Icons.language_rounded,
            title: 'App Language',
            subtitle: 'Language • Region • Preferences',
            trailingText: _profile.language,
            onTap: _openLanguagePage,
          ),
          _settingsDivider(colorScheme),
          _settingsRow(
            context,
            icon: Icons.palette_outlined,
            title: 'App Theme',
            subtitle: 'Display • Appearance • Theme',
            trailingText: themeModeLabel(themeNotifier.value),
            onTap: _openThemeSettingsPage,
          ),
          _settingsDivider(colorScheme),
          _settingsRow(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Support Center',
            subtitle: 'Help • Contact • Support',
            trailingText: null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportCenterPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _settingsDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant.withOpacity(0.75),
      ),
    );
  }

  Widget _settingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String? trailingText,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.5,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

}
