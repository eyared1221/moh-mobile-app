import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signin_screen.dart';
import 'verify_email_screen.dart';
import 'auth_success_dialog.dart';
import 'auth_error_handler.dart';
import 'auth_messages.dart';
import 'password_validator.dart';
import 'contact_validation.dart';
import '../data/auth_models.dart';
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
  final _ageCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  final AuthController _authController = AuthController.standard();

  @override
  void dispose() {
    _contactCtrl.dispose();
    _usernameCtrl.dispose();
    _ageCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateContact(String? value) {
    return ContactValidation.validate(value);
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return AuthMessages.ageRequired;
    final age = int.tryParse(value.trim());
    if (age == null) return AuthMessages.invalidAge;
    if (age < 10) return AuthMessages.ageMin;
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _authController.register(
        contact: _contactCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
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
      showAuthErrorDialog(
        context,
        message: AuthErrorHandler.getMessage(error),
      );
    }
  }

  void _changeAge(int delta) {
    final current = int.tryParse(_ageCtrl.text.trim());
    final next = current == null ? 10 : current + delta;
    if (next < 10) {
      return;
    }
    setState(() {
      _ageCtrl.text = next.toString();
      _ageCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _ageCtrl.text.length),
      );
    });
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF005C8F);
    final errorColor = Theme.of(context).colorScheme.error;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: primaryColor, size: 22),
      filled: true,
      fillColor: isDark ? const Color(0xFF161D2C) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
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
    final primaryColor = const Color(0xFF005C8F);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87, size: 20),
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
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Enter your email or phone number', Icons.contact_mail_outlined, context),
                    validator: _validateContact,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _usernameCtrl,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Enter a username', Icons.person_outline_rounded, context),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : AuthMessages.usernameRequired,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Age', Icons.cake_outlined, context).copyWith(
                      hintText: 'Enter you Age',
                      suffixIcon: SizedBox(
                        width: 44,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _changeAge(1),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 6, bottom: 2),
                                child: Icon(Icons.keyboard_arrow_up_rounded, size: 20),
                              ),
                            ),
                            InkWell(
                              onTap: () => _changeAge(-1),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 2, bottom: 6),
                                child: Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    validator: _validateAge,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Enter your password', Icons.lock_outline_rounded, context).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[400],
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Re-enter your password', Icons.verified_user_outlined, context).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[400],
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return AuthMessages.confirmPasswordRequired;
                      final passwordError = validatePassword(v);
                      if (passwordError != null) return passwordError;
                      if (v != _passwordCtrl.text) return AuthMessages.passwordsDoNotMatch;
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms and conditions',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _handleSignUp,
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 48),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => SignInScreen(language: widget.language))
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
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
