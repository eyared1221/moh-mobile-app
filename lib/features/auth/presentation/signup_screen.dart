import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signin_screen.dart';
import 'verify_email_screen.dart';
import 'auth_success_dialog.dart';
import '../data/auth_models.dart';
import '../data/auth_service.dart';

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
  final AuthService _authService = AuthService.instance;

  @override
  void initState() {
    super.initState();
    _ageCtrl.text = '10';
    _ageCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _ageCtrl.text.length),
    );
  }

  @override
  void dispose() {
    _contactCtrl.dispose();
    _usernameCtrl.dispose();
    _ageCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return RegExp(r'^(09|07)\d{8}$').hasMatch(digits);
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required';
    }
    final v = value.trim();
    if (v.contains('@')) {
      return _isValidEmail(v) ? null : 'Enter a valid email address';
    }
    if (_isValidPhone(v)) return null;
    return 'Phone number must be 10 digits and start with 09 or 07';
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final age = int.tryParse(value.trim());
    if (age == null) return 'Enter a valid age';
    if (age < 10) return 'Age must be at least 10';
    if (age > 24) return 'Age must be 24 or below';
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
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
            : 'Your account has been created successfully.',
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
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAuthErrorDialog(context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAuthErrorDialog(
        context,
        message: 'Failed to create account. Please try again.',
      );
    }
  }

  void _changeAge(int delta) {
    final current = int.tryParse(_ageCtrl.text.trim()) ?? 10;
    final next = (current + delta).clamp(10, 24);
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
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
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details to create an account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _contactCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final text = newValue.text;
                        if (text.isEmpty || text.contains('@')) {
                          return newValue;
                        }

                        if (!RegExp(r'^\d*$').hasMatch(text)) {
                          return oldValue;
                        }

                        if (text.length > 10) {
                          return oldValue;
                        }

                        if (text.length >= 2 &&
                            !text.startsWith('09') &&
                            !text.startsWith('07')) {
                          return oldValue;
                        }

                        if (text.length == 1 && text != '0') {
                          return oldValue;
                        }

                        return newValue;
                      }),
                    ],
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
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Username is required',
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final text = newValue.text;
                        if (text.isEmpty) return newValue;
                        final age = int.tryParse(text);
                        if (age == null) return oldValue;
                        if (text.length == 1) {
                          return (text == '1' || text == '2') ? newValue : oldValue;
                        }
                        return (age >= 10 && age <= 24) ? newValue : oldValue;
                      }),
                    ],
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Enter your age', Icons.cake_outlined, context).copyWith(
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
                    validator: (v) => (v != null && v.length >= 8) ? null : 'Min 8 characters required',
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
                      if (v == null || v.isEmpty) return 'Please confirm password';
                      if (v.length < 8) return 'Min 8 characters required';
                      if (v != _passwordCtrl.text) return 'Passwords do not match';
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
                    height: 54,
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
                        : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
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
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
