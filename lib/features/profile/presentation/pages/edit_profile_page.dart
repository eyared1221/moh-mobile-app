import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/responsive/responsive_container.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../domain/entities/profile_user_entity.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.profile,
  });

  final ProfileUserEntity profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _ageController = TextEditingController(text: widget.profile.age.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return AuthMessages.ageRequired;

    final age = int.tryParse(value.trim());
    if (age == null) return AuthMessages.invalidAge;
    if (age < 10) return AuthMessages.ageMin;

    return null;
  }

  String get _primaryContact {
    final phone = widget.profile.phone.trim();
    if (phone.isNotEmpty) {
      return phone;
    }

    final email = widget.profile.email.trim();
    if (email.isNotEmpty) {
      return email;
    }

    return 'Not available';
  }

  String get _primaryContactLabel {
    if (widget.profile.phone.trim().isNotEmpty) {
      return 'Phone Number';
    }

    if (widget.profile.email.trim().isNotEmpty) {
      return 'Email Address';
    }

    return 'Contact Details';
  }

  IconData get _primaryContactIcon {
    if (widget.profile.phone.trim().isNotEmpty) {
      return Icons.call_rounded;
    }

    return Icons.alternate_email_rounded;
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      widget.profile.copyWith(
        fullName: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF4F5F8);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
        centerTitle: true,
        title: Text(
          'Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : colorScheme.primary,
          ),
        ),
      ),
      body: ResponsiveContainer.safe(
        child: ResponsiveContainer.scrollable(
          context: context,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Manage your account details and the health profile used across Wise Youth.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                _SectionCard(
                  title: 'Your Info',
                  accent: colorScheme.primary,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: _primaryContactIcon,
                        title: _primaryContact,
                        subtitle: _primaryContactLabel == 'Phone Number'
                            ? 'Phone Number'
                            : _primaryContactLabel == 'Email Address'
                                ? 'Email Address'
                                : 'Contact Details',
                      ),
                      _CardDivider(color: colorScheme.outlineVariant),
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        title: widget.profile.fullName.trim().isEmpty
                            ? 'Yegna User'
                            : widget.profile.fullName.trim(),
                        subtitle: 'Profile Name',
                      ),
                      _CardDivider(color: colorScheme.outlineVariant),
                      _InfoRow(
                        icon: Icons.language_rounded,
                        title: widget.profile.language.trim().isEmpty
                            ? 'English'
                            : widget.profile.language.trim(),
                        subtitle: 'Language Preference',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your contact details are managed from your account data. Name and age are used to personalize support content.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  child: Column(
                    children: [
                      _EditField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) =>
                            value != null && value.trim().isNotEmpty
                                ? null
                                : AuthMessages.usernameRequired,
                      ),
                      const SizedBox(height: 14),
                      _EditField(
                        controller: _ageController,
                        label: 'Age',
                        hintText: 'Enter your age',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: _validateAge,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            if (text.isEmpty || !text.startsWith('0')) {
                              return newValue;
                            }
                            return oldValue;
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your age helps tailor health support, learning content, and mentor guidance in the app.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
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
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.title,
    this.accent,
  });

  final Widget child;
  final String? title;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: accent ?? colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: color.withOpacity(0.7),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      ) ??
                      TextStyle(
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
                      ) ??
                      TextStyle(
                        fontSize: 13.5,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: colorScheme.primary,
          size: 22,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF161D2C) : const Color(0xFFF6F7FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.85),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}
