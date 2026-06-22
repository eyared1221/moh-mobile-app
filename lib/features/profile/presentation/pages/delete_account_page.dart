import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_container.dart';
import '../../../auth/data/auth_session_storage.dart';
import '../../data/profile_api_client.dart';
import '../../../guest/presentation/guest_page.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  static const _dangerColor = Color(0xFFD92D20);

  final _apiClient = ProfileApiClient();
  final _passwordController = TextEditingController();

  String? _userContact;
  String _contactLabel = 'Email';

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserContact();
  }

  Future<void> _loadUserContact() async {
    final email = await AuthSessionStorage.getEmail();
    final phone = await AuthSessionStorage.getPhone();

    final trimmedEmail = email?.trim() ?? '';
    final trimmedPhone = phone?.trim() ?? '';

    if (!mounted) return;

    setState(() {
      if (trimmedEmail.isNotEmpty) {
        _contactLabel = 'Email';
        _userContact = trimmedEmail;
      } else if (trimmedPhone.isNotEmpty) {
        _contactLabel = 'Phone Number';
        _userContact = trimmedPhone;
      } else {
        _contactLabel = 'Email or Phone';
        _userContact = null;
      }
    });
  }

  String _maskedContact() {
    final contact = _userContact?.trim() ?? '';

    if (contact.isEmpty) {
      return 'Not available';
    }

    if (_contactLabel == 'Email') {
      final atIndex = contact.indexOf('@');

      if (atIndex <= 1 || atIndex == contact.length - 1) {
        return contact;
      }

      final localPart = contact.substring(0, atIndex);
      final domainPart = contact.substring(atIndex + 1);
      final dotIndex = domainPart.lastIndexOf('.');

      if (dotIndex <= 0 || dotIndex == domainPart.length - 1) {
        final visibleLocal = localPart.substring(0, 1);
        final hiddenLocal = '*' * (localPart.length - 1);

        return '$visibleLocal$hiddenLocal@$domainPart';
      }

      final domainName = domainPart.substring(0, dotIndex);
      final domainSuffix = domainPart.substring(dotIndex);

      final visibleLocal = localPart.substring(0, 1);
      final hiddenLocal = '*' * (localPart.length - 1);

      final visibleDomain = domainName.substring(0, 1);
      final hiddenDomain = '*' * (domainName.length - 1);

      return '$visibleLocal$hiddenLocal@$visibleDomain$hiddenDomain$domainSuffix';
    }

    if (_contactLabel != 'Phone Number') {
      return contact;
    }

    if (contact.length <= 4) {
      return '*' * contact.length;
    }

    final visibleStart = contact.length > 7 ? 3 : 2;
    final visibleEnd = 2;

    final hiddenCount =
        contact.length - visibleStart - visibleEnd;

    if (hiddenCount <= 0) {
      return contact;
    }

    return '${contact.substring(0, visibleStart)}${'*' * hiddenCount}${contact.substring(contact.length - visibleEnd)}';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter your password',
          ),
          backgroundColor: _dangerColor,
        ),
      );

      return;
    }

    final confirmed = await _showDeleteConfirmation();

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _apiClient.delete(
        '/profile',
        body: {
          'password': _passwordController.text,
        },
      );

      if (!mounted) return;

      await _showDeletedDialog();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete account: $e',
          ),
          backgroundColor: _dangerColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete account?',
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
          content: Text(
            'This action is permanent. Your profile and account data will be removed.',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeletedDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Account deleted',
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
          content: Text(
            'Your account has been deleted successfully.',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await AuthSessionStorage.clear();

                if (!mounted) return;

                Navigator.of(dialogContext).pop();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const GuestPage(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.primary,

        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),

      body: ResponsiveContainer.safe(
        child: ResponsiveContainer.scrollable(
          context: context,
          child: ResponsiveContainer.adaptive(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                Text(
                  'Before You Continue',
                  style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.15,
                        color: colorScheme.onSurface,
                      ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Deleting your account permanently removes your profile and saved account data.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),

                const SizedBox(height: 28),

                _sectionTitle(
                  context,
                  'Account Details',
                ),

                const SizedBox(height: 10),

                _AccountContactDisplay(
                  label: _contactLabel,
                  value: _maskedContact(),
                  icon: _contactLabel == 'Phone Number'
                      ? Icons.phone_outlined
                      : Icons.person_outline_rounded,
                ),

                const SizedBox(height: 22),

                _sectionTitle(
                  context,
                  'Confirm Password',
                ),

                const SizedBox(height: 10),

                _DeletePasswordField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 22),

                _sectionTitle(
                  context,
                  'Important Notice',
                ),

                const SizedBox(height: 10),

                _warningSection(context),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _deleteAccount,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: _dangerColor,

                      disabledBackgroundColor:
                          _dangerColor.withOpacity(0.45),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      padding: const EdgeInsets.symmetric(
                        vertical: 17,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(999),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String text,
  ) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 0.4,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _warningSection(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: _dangerColor.withOpacity(0.08),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: _dangerColor.withOpacity(0.22),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          14,
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color:
                    _dangerColor.withOpacity(0.12),

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: const Icon(
                Icons.warning_amber_rounded,
                color: _dangerColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                'You will lose access to your saved profile data and account history after deletion.',

                style:
                    theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color:
                              colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountContactDisplay extends StatelessWidget {
  const _AccountContactDisplay({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF161D2C) : const Color(0xFFF8FAFC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF005C8F),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ) ??
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletePasswordField extends StatelessWidget {
  const _DeletePasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF005C8F),
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: isDark ? Colors.grey[400] : Colors.grey[400],
          ),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF161D2C) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF005C8F), width: 2),
        ),
        errorStyle: TextStyle(color: colorScheme.error),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
    );
  }
}
