import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/responsive/responsive_spacing.dart';
import '../../../../core/responsive/responsive_text.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

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
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: ResponsiveSpacing.xlSpacing(context)),
                  // Lock Icon Container
                  _LockIconContainer(context: context),
                  SizedBox(height: ResponsiveSpacing.xxxlSpacing(context)),
                  // Title
                  Text(
                    'Change Password',
                    style: ResponsiveText.titleStyle(
                      context,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveSpacing.mdSpacing(context)),
                  // Subtitle
                  Text(
                    'Enter your current password and a new password to update your account security.',
                    textAlign: TextAlign.center,
                    style: ResponsiveText.bodyStyle(
                      context,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: ResponsiveSpacing.xxxlSpacing(context)),
                  // Old Password Field
                  _PasswordField(
                    context: context,
                    controller: _oldPasswordController,
                    label: 'Old Password',
                    obscureText: _obscureOldPassword,
                    onToggleVisibility: () {
                      setState(() => _obscureOldPassword = !_obscureOldPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your old password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveSpacing.lgSpacing(context)),
                  // New Password Field
                  _PasswordField(
                    context: context,
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveSpacing.lgSpacing(context)),
                  // Confirm Password Field
                  _PasswordField(
                    context: context,
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveSpacing.xxxlSpacing(context)),
                  // Confirm Change Button
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveSpacing.xxxlSpacing(context),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveSpacing.lgSpacing(context),
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: ResponsiveSpacing.lgSpacing(context),
                              height: ResponsiveSpacing.lgSpacing(context),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Confirm Change',
                              style: ResponsiveText.buttonStyle(
                                context,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: ResponsiveSpacing.xlSpacing(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LockIconContainer extends StatelessWidget {
  final BuildContext context;

  const _LockIconContainer({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.lock_outline,
        size: 60,
        color: kPrimary,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.context,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.lgSpacing(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: ResponsiveText.bodyStyle(
            context,
            color: colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveSpacing.lgSpacing(context),
            ),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveSpacing.xlSpacing(context),
            vertical: ResponsiveSpacing.xlSpacing(context),
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
