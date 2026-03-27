import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'auth_success_dialog.dart';
import '../data/auth_models.dart';
import '../data/auth_service.dart';
import 'package:yegna_health/features/home/presentation/home_page.dart';

class SignInScreen extends StatefulWidget {
  final String? language;
  const SignInScreen({super.key, this.language});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  bool _obscure = true;
  bool _isLoading = false; // Loading state for professional feel
  final AuthService _authService = AuthService.instance;

  @override
  void dispose() {
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 9 && digits.length <= 15;
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
    return 'Enter a valid email or phone number';
  }

  // Simulate a network request
  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        identifier: _contactCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      showAuthSuccessDialog(
        context,
        message: 'You have logged in successfully.',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            ageRange: result.user.ageGroup,
            userName: result.user.username,
          ),
        ),
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign in. Please try again.')),
      );
    }
  }

  InputDecoration _modernInput(String label, IconData icon, BuildContext context) {
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

    return GestureDetector(
      // Tapping outside closes keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : const Color(0xFF005C8F),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                    
                    // Hero Animation for Logo smoothness
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image is missing
                          return Icon(Icons.health_and_safety, size: 80, color: const Color(0xFF005C8F));
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 22),
                    Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF005C8F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Inputs
                    TextFormField(
                      controller: _contactCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _modernInput('Email or Phone Number', Icons.alternate_email, context),
                      validator: _validateContact,
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _modernInput('Password', Icons.lock_outline, context).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                            color: isDark ? Colors.grey[400] : Colors.grey[400]
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Password is required' : null,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ForgotPasswordScreen(language: widget.language)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005C8F))),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Loading Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005C8F),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: const Color(0xFF005C8F).withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isLoading ? null : _handleSignIn,
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen(language: widget.language))),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005C8F)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}
