import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signin_screen.dart';
import 'verify_email_screen.dart';
import 'auth_success_dialog.dart';
import 'auth_error_handler.dart';
import 'auth_messages.dart';
import 'password_validator.dart';
import 'contact_validation.dart';
import '../../profile/presentation/pages/privacy_policy_page.dart';
import '../../profile/presentation/pages/terms_conditions_page.dart';
import 'controllers/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  final String? language;
  const SignUpScreen({super.key, this.language});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _contactCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dateOfBirthCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _hasAcceptedTerms = false;
  DateTime? _selectedDateOfBirth;
  Timer? _usernameCheckTimer;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  String? _checkedUsername;
  final AuthController _authController = AuthController.standard();
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTermsAndConditions;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
  }

  @override
  void dispose() {
    _usernameCheckTimer?.cancel();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _contactCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _dateOfBirthCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthMessages.emailRequired;
    }

    return ContactValidation.isValidEmail(value)
        ? null
        : AuthMessages.invalidEmail;
  }

  int _ageFromDateOfBirth(DateTime dateOfBirth) {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String? _validateDateOfBirth(String? _) {
    final dateOfBirth = _selectedDateOfBirth;
    if (dateOfBirth == null) return AuthMessages.ageRequired;
    if (_ageFromDateOfBirth(dateOfBirth) < 10) return AuthMessages.ageMin;
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthMessages.phoneRequired;
    }

    return ContactValidation.isValidPhone(value)
        ? null
        : AuthMessages.invalidPhone;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthMessages.usernameRequired;
    }
    if (_checkedUsername == value.trim() && _isUsernameAvailable == false) {
      return 'This username is already taken';
    }
    return null;
  }

  void _onUsernameChanged(String value) {
    _usernameCheckTimer?.cancel();
    final username = value.trim();
    setState(() {
      _checkedUsername = null;
      _isUsernameAvailable = null;
      _isCheckingUsername = false;
    });

    if (username.isEmpty) return;
    _usernameCheckTimer = Timer(
      const Duration(milliseconds: 500),
      () => _checkUsernameAvailability(username),
    );
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (!mounted || _usernameCtrl.text.trim() != username) return;
    setState(() => _isCheckingUsername = true);

    try {
      final available = await _authController.isUsernameAvailable(username);
      if (!mounted || _usernameCtrl.text.trim() != username) return;
      setState(() {
        _checkedUsername = username;
        _isUsernameAvailable = available;
        _isCheckingUsername = false;
      });
    } catch (_) {
      if (!mounted || _usernameCtrl.text.trim() != username) return;
      setState(() => _isCheckingUsername = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_hasAcceptedTerms) return;
    final username = _usernameCtrl.text.trim();
    if (username.isNotEmpty &&
        (_checkedUsername != username || _isUsernameAvailable != true)) {
      await _checkUsernameAvailability(username);
    }
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _authController.register(
        email: _contactCtrl.text.trim(),
        username: username,
        phone: _phoneCtrl.text.trim(),
        age: _ageFromDateOfBirth(_selectedDateOfBirth!),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      showAuthSuccessDialog(
        context,
        message: result.message.isNotEmpty
            ? result.message
            : AuthMessages.signUpSuccess,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            language: widget.language,
            contact: _contactCtrl.text.trim(),
            userName: result.user.username,
            age: result.user.age,
            debugCode: result.debugCode,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAuthErrorDialog(context, message: AuthErrorHandler.getMessage(error));
    }
  }

  void _openTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsConditionsPage()),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final earliestAllowedDate = DateTime(now.year - 999, now.month, now.day);
    final latestAllowedDate = DateTime(now.year - 10, now.month, now.day);
    final initialDate =
        _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(latestAllowedDate)
          ? latestAllowedDate
          : initialDate,
      firstDate: earliestAllowedDate,
      lastDate: latestAllowedDate,
      helpText: 'Select your date of birth',
      fieldHintText: 'DD/MM/YY',
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _selectedDateOfBirth = selectedDate;
      _dateOfBirthCtrl.text = _formatDate(selectedDate);
    });
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year.toString().substring(2)}';
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF005C8F);
    final errorColor = Theme.of(context).colorScheme.error;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: primaryColor, size: 22),
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
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorStyle: TextStyle(color: errorColor),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF005C8F);
    final canCreateAccount = _hasAcceptedTerms && !_isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter your details to create an account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _contactCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: _buildInputDecoration(
                      'Enter your email',
                      Icons.contact_mail_outlined,
                      context,
                    ),
                    validator: _validateContact,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _usernameCtrl,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onChanged: _onUsernameChanged,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration:
                        _buildInputDecoration(
                          'Enter a username',
                          Icons.person_outline_rounded,
                          context,
                        ).copyWith(
                          helperText: _isCheckingUsername
                              ? 'Checking username...'
                              : _isUsernameAvailable == true
                              ? 'Username available'
                              : _isUsernameAvailable == false
                              ? 'Username taken'
                              : null,
                          helperStyle: TextStyle(
                            color: _isUsernameAvailable == true
                                ? Colors.green.shade700
                                : _isUsernameAvailable == false
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                          suffixIcon: _isCheckingUsername
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _isUsernameAvailable == true
                              ? Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green.shade700,
                                )
                              : _isUsernameAvailable == false
                              ? Icon(
                                  Icons.cancel_outlined,
                                  color: Theme.of(context).colorScheme.error,
                                )
                              : null,
                        ),
                    validator: _validateUsername,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: _buildInputDecoration(
                      'Enter your phone number',
                      Icons.phone_outlined,
                      context,
                    ),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _dateOfBirthCtrl,
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    onTap: _selectDateOfBirth,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration:
                        _buildInputDecoration(
                          'Date of birth',
                          Icons.cake_outlined,
                          context,
                        ).copyWith(
                          hintText: 'DD/MM/YY',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                    validator: _validateDateOfBirth,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration:
                        _buildInputDecoration(
                          'Enter your password',
                          Icons.lock_outline_rounded,
                          context,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[400],
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration:
                        _buildInputDecoration(
                          'Re-enter your password',
                          Icons.verified_user_outlined,
                          context,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[400],
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return AuthMessages.confirmPasswordRequired;
                      final passwordError = validatePassword(v);
                      if (passwordError != null) return passwordError;
                      if (v != _passwordCtrl.text)
                        return AuthMessages.passwordsDoNotMatch;
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _hasAcceptedTerms,
                              onChanged: (value) {
                                setState(() {
                                  _hasAcceptedTerms = value ?? false;
                                });
                              },
                              activeColor: primaryColor,
                              side: const BorderSide(
                                color: primaryColor,
                                width: 1.4,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'I have read and agree to the ',
                                ),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: _termsRecognizer,
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: _privacyRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                        disabledBackgroundColor: primaryColor.withOpacity(0.48),
                        disabledForegroundColor: Colors.white.withOpacity(0.78),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: canCreateAccount ? _handleSignUp : null,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SignInScreen(language: widget.language),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
