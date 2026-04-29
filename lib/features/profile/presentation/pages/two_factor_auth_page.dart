import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorAuthPage extends StatelessWidget {
  const TwoFactorAuthPage({super.key, this.email});

  final String? email;

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use SMS or an authenticator app to add an extra sign-in step.'),
      ),
    );
  }

  Future<void> _openMethodSelection(BuildContext context) async {
    final enabled = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TwoFactorMethodPage(email: email),
      ),
    );

    if (context.mounted && enabled == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        titleSpacing: 0,
        title: const Text(
          'Two-factor authentication',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_rounded),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure your account with two-factor authentication (2FA).',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 26),
              _InfoRow(
                icon: Icons.lock_outline_rounded,
                accentColor: const Color(0xFFF59B8F),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'This provides additional security by requiring an authentication '
                            'code whenever you sign in with a new device. ',
                      ),
                      TextSpan(
                        text: 'Learn more',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _InfoRow(
                icon: Icons.smartphone_rounded,
                accentColor: const Color(0xFF91A4B8),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Your phone number or authenticator app helps keep your account '
                            'secure by adding an additional layer of protection. You always '
                            'decide how your phone number will be used. ',
                      ),
                      TextSpan(
                        text: 'Learn more',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openMethodSelection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Set up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Note: Your current sessions will stay active, but you will need to '
                'enter a second factor the next time you sign in.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TwoFactorMethodPage extends StatefulWidget {
  const TwoFactorMethodPage({super.key, this.email});

  final String? email;

  @override
  State<TwoFactorMethodPage> createState() => _TwoFactorMethodPageState();
}

class _TwoFactorMethodPageState extends State<TwoFactorMethodPage> {
  static const List<String> _methods = [
    'Authenticator App',
    'Phone Number (SMS)',
  ];

  String _selectedMethod = _methods.first;

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected method: $_selectedMethod'),
      ),
    );
  }

  Future<void> _continueSetup() async {
    if (_selectedMethod == 'Authenticator App') {
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AuthenticatorVerificationPage(email: widget.email),
        ),
      );

      if (!mounted || verified != true) return;
      Navigator.pop(context, true);
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        titleSpacing: 0,
        title: const Text(
          'Two-factor authentication',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_rounded),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure your account with two-factor authentication (2FA).',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'Choose your authentication method:',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
                items: _methods
                    .map(
                      (method) => DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedMethod = value);
                },
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurfaceVariant),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: theme.cardColor,
              ),
              const SizedBox(height: 38),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Note: Your current sessions will stay active, but you will need to '
                'enter a second factor (SMS or Authenticator) whenever you sign in again.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthenticatorVerificationPage extends StatefulWidget {
  const AuthenticatorVerificationPage({super.key, this.email});

  final String? email;

  @override
  State<AuthenticatorVerificationPage> createState() => _AuthenticatorVerificationPageState();
}

class _AuthenticatorVerificationPageState extends State<AuthenticatorVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  String? _destinationEmail;

  @override
  void initState() {
    super.initState();
    final incomingEmail = widget.email?.trim() ?? '';
    if (incomingEmail.isNotEmpty) {
      _destinationEmail = incomingEmail;
    }
    _loadDestinationEmail();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinationEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionEmail = prefs.getString('userEmail')?.trim() ?? '';
    final profileEmail = prefs.getString('profile_email')?.trim() ?? '';
    final incomingEmail = widget.email?.trim() ?? '';
    final resolvedEmail = sessionEmail.isNotEmpty
        ? sessionEmail
        : incomingEmail.isNotEmpty
            ? incomingEmail
            : profileEmail;

    if (!mounted || resolvedEmail.isEmpty) return;
    setState(() => _destinationEmail = resolvedEmail);
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enter the 6-digit verification code from your email.'),
      ),
    );
  }

  void _submitCode() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: colorScheme.onSurface,
          titleSpacing: 0,
          title: const Text(
            'Authenticator App',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: () => _showHelp(context),
              icon: const Icon(Icons.help_rounded),
              tooltip: 'Help',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We sent a code to your email',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _destinationEmail == null || _destinationEmail!.isEmpty
                      ? 'Enter the 6-digit code sent to'
                      : 'Enter the 6-digit code sent to\n$_destinationEmail',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 335,
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '6-digit code',
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _submitCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'If you don’t see the email in your inbox, check your spam folder.',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  final IconData icon;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 30,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(child: child),
      ],
    );
  }
}
