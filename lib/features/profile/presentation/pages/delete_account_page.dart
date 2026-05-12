import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/responsive/responsive_spacing.dart';
import '../../../../core/responsive/responsive_text.dart';
import '../../../auth/data/auth_session_storage.dart';
import '../../data/profile_api_client.dart';
import '../../../guest/presentation/guest_page.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
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

    if (mounted) {
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
    final hiddenCount = contact.length - visibleStart - visibleEnd;

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
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSpacing.xlSpacing(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                textAlign: TextAlign.center,
                style: ResponsiveText.titleStyle(
                  context,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xlSpacing(context)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveSpacing.lgSpacing(context),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: ResponsiveText.buttonStyle(
                          context,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveSpacing.smSpacing(context)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveSpacing.lgSpacing(context),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: ResponsiveText.buttonStyle(
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _apiClient.delete(
        '/profile',
        body: {'password': _passwordController.text},
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Account Deleted'),
          content: const Text('You have deleted your account successfully.'),
          actions: [
            TextButton(
              onPressed: () async {
                await AuthSessionStorage.clear();
                if (!mounted) return;
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const GuestPage()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        ),
        title: Text(
          'Delete Account',
          style: ResponsiveText.titleStyle(
            context,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveContainer.safe(
        child: ResponsiveContainer.scrollable(
          context: context,
          child: ResponsiveContainer.adaptive(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveSpacing.xlSpacing(context)),
                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProgressIndicator(),
                    const SizedBox(width: 8),
                    _ProgressIndicator(),
                    const SizedBox(width: 8),
                    _ProgressIndicator(),
                  ],
                ),
                SizedBox(height: ResponsiveSpacing.xxxlSpacing(context)),
                // Title
                Text(
                  'Confirm you are happy to proceed',
                  style: ResponsiveText.titleStyle(
                    context,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.mdSpacing(context)),
                // Description
                Text(
                  "Please note this is permanent and can't be undone. To confirm deleting your account, please review your contact and enter your password below:",
                  style: ResponsiveText.bodyStyle(
                    context,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.xxxlSpacing(context)),
                // Email label
                Text(
                  _contactLabel,
                  style: ResponsiveText.bodyStyle(
                    context,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.smSpacing(context)),
                // Contact field (read-only)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSpacing.lgSpacing(context),
                    vertical: ResponsiveSpacing.lgSpacing(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _maskedContact(),
                    style: ResponsiveText.bodyStyle(
                      context,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.xlSpacing(context)),
                // Password label
                Text(
                  'Password',
                  style: ResponsiveText.bodyStyle(
                    context,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.smSpacing(context)),
                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSpacing.lgSpacing(context),
                        vertical: ResponsiveSpacing.lgSpacing(context),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.xxxlSpacing(context)),
                // Delete button
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveSpacing.xxxlSpacing(context),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                            'Delete',
                            style: ResponsiveText.buttonStyle(
                              context,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
