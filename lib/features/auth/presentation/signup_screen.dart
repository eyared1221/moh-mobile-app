import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signin_screen.dart';
import 'package:yegna_health/features/home/presentation/home_page.dart';

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

  int? _selectedAge;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final List<int> _ages = List<int>.generate(15, (i) => i + 10); // 10-24

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

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final age = int.tryParse(value.trim());
    if (age == null) return 'Enter a valid age';
    if (age < 10 || age > 24) return 'Age must be between 10 and 24';
    return null;
  }

  String _ageToRange(int age) {
    if (age <= 14) return '10-14';
    if (age <= 19) return '15-19';
    return '20-24';
  }

  void _showAgePicker() {
    final current = _selectedAge ?? 15;
    final index = _ages.indexOf(current);
    final controller = ScrollController(
      initialScrollOffset: (index >= 0 ? index : 0) * 48.0,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            controller: controller,
            itemCount: _ages.length,
            itemBuilder: (context, i) {
              final age = _ages[i];
              final selected = age == _selectedAge;
              return ListTile(
                title: Text(
                  age.toString(),
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                trailing: selected ? const Icon(Icons.check_rounded) : null,
                onTap: () {
                  setState(() {
                    _selectedAge = age;
                    _ageCtrl.text = age.toString();
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    // Simulate saving account
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _usernameCtrl.text.trim());
    final ageValue = int.parse(_ageCtrl.text.trim());
    final ageRange = _ageToRange(ageValue);
    await prefs.setString('userAge', ageRange);
    await prefs.setString('userContact', _contactCtrl.text.trim());
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;
    setState(() => _isLoading = false);
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          ageRange: ageRange,
          userName: _usernameCtrl.text.trim(),
        ),
      ),
      (route) => false,
    );
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
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 72,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.health_and_safety, size: 60, color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details to create your account.',
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
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Email or Phone Number', Icons.alternate_email, context),
                    validator: _validateContact,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _usernameCtrl,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Username', Icons.person_outline, context),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Username is required',
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _buildInputDecoration('Age', Icons.calendar_today_outlined, context),
                            validator: _validateAge,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _showAgePicker,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: isDark ? const Color(0xFF161D2C) : const Color(0xFFF8FAFC),
                            ),
                            child: Icon(
                              Icons.expand_more,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Password', Icons.lock_outline, context).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[400],
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 characters required',
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Confirm Password', Icons.lock_reset_outlined, context).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[400],
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) return 'Passwords do not match';
                      if (v == null || v.isEmpty) return 'Please confirm password';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

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
