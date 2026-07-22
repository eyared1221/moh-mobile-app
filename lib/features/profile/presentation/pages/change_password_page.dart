import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../../auth/presentation/password_validator.dart';
import '../../../notifications/data/notification_automation_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController.standard();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authController.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      unawaited(
        NotificationAutomationService.instance.notifyPasswordChanged(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ResponsiveContainer.safe(
        child: ResponsiveContainer.scrollable(
          context: context,
          child: ResponsiveContainer.adaptive(
            context: context,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Text(
                    'Update Your Password',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Use a strong password to keep your account secure.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle(context, 'Password Details'),
                  const SizedBox(height: 10),

                  Column(
                    children: [
                      _PasswordField(
                        controller: _oldPasswordController,
                        label: 'Current Password',
                        obscureText: _obscureOldPassword,
                        onToggleVisibility: () {
                          setState(
                            () => _obscureOldPassword =
                                !_obscureOldPassword,
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(
                            () => _obscureNewPassword =
                                !_obscureNewPassword,
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return validatePassword(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AuthMessages.confirmPasswordRequired;
                          }
                          final passwordError = validatePassword(value);
                          if (passwordError != null) return passwordError;
                          if (value != _newPasswordController.text) {
                            return AuthMessages.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _securityNote(context),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        disabledBackgroundColor: kPrimary.withOpacity(0.45),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
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
                              'Save New Password',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        letterSpacing: 0.4,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _securityNote(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                color: colorScheme.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Choose a password with at least 8 characters, at least one non-space character, no leading or trailing spaces, and spaces only in the middle if needed.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
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
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
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
