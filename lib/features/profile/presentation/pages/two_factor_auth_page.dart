import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorAuthPage extends StatelessWidget {
  const TwoFactorAuthPage({super.key, this.email});

  final String? email;

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Use SMS or an authenticator app to add an extra sign-in step.',
        ),
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
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.primary,
        title: const Text(
          'Two-Factor Auth',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              'Protect Your Account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an extra verification step when signing in from a new device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle(context, 'Security Details'),
            const SizedBox(height: 10),

            _infoSection(
              context,
              children: [
                _infoTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: 'Extra Verification',
                  subtitle:
                      'A security code is required when signing in from a new device.',
                ),
                _sectionDivider(colorScheme),
                _infoTile(
                  context,
                  icon: Icons.smartphone_rounded,
                  title: 'Verification Method',
                  subtitle:
                      'Use SMS or an authenticator app to protect your account.',
                ),
              ],
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openMethodSelection(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Continue Setup',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'Your current sessions will stay active. You will enter a second factor the next time you sign in.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
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
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.primary,
        title: const Text(
          'Two-Factor Auth',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              'Choose Verification Method',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how you want to receive your security code.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle(context, 'Method'),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              items: _methods
                  .map(
                    (method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(
                        method,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
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
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.4,
                  ),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              dropdownColor: theme.cardColor,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continueSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'You will need this verification method when signing in again.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthenticatorVerificationPage extends StatefulWidget {
  const AuthenticatorVerificationPage({super.key, this.email});

  final String? email;

  @override
  State<AuthenticatorVerificationPage> createState() =>
      _AuthenticatorVerificationPageState();
}

class _AuthenticatorVerificationPageState
    extends State<AuthenticatorVerificationPage> {
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
          centerTitle: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: colorScheme.primary,
          title: const Text(
            'Verify Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showHelp(context),
              icon: const Icon(Icons.help_outline_rounded),
              tooltip: 'Help',
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                'Check Your Email',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _destinationEmail == null || _destinationEmail!.isEmpty
                    ? 'Enter the 6-digit code sent to your email.'
                    : 'Enter the 6-digit code sent to $_destinationEmail.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle(context, 'Verification Code'),
              const SizedBox(height: 10),

              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '6-digit code',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Verify Code',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'If you don’t see the email in your inbox, check your spam folder.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
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

Widget _infoSection(
  BuildContext context, {
  required List<Widget> children,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Container(
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: colorScheme.outlineVariant),
    ),
    child: Column(children: children),
  );
}

Widget _sectionDivider(ColorScheme colorScheme) {
  return Padding(
    padding: const EdgeInsets.only(left: 76, right: 18),
    child: Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant.withOpacity(0.75),
    ),
  );
}

Widget _infoTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}