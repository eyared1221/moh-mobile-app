import 'package:flutter/material.dart';
import 'verify_reset_code_screen.dart';
import 'auth_success_dialog.dart';
import 'auth_error_handler.dart';
import 'auth_messages.dart';
import 'contact_validation.dart';
import 'controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? language;

  const ForgotPasswordScreen({super.key, this.language});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  bool _isLoading = false;
  final AuthController _authController = AuthController.standard();

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthMessages.emailRequired;
    }

    return ContactValidation.isValidEmail(value)
        ? null
        : AuthMessages.invalidEmail;
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF005C8F);
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

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final contact = _contactCtrl.text.trim();
      final result = await _authController.forgotPassword(contact: contact);

      if (!mounted) return;
      setState(() => _isLoading = false);

      showAuthSuccessDialog(
        context,
        message: result.debugCode == null
            ? result.message
            : '${result.message} Use ${result.debugCode}.',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyResetCodeScreen(
            language: widget.language,
            contact: contact,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF005C8F);

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
                    child: Image.asset(
                      'assets/images/forgot-password.png',
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(isDark ? 0.18 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset_outlined,
                            size: 40,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Forgot Password?',
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
                    'Enter your email and we will generate a password reset code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _contactCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _buildInputDecoration('Enter your email', Icons.contact_mail_outlined, context),
                    validator: _validateEmail,
                    onFieldSubmitted: (_) => _isLoading ? null : _handleReset(),
                  ),
                  const SizedBox(height: 20),
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
                      onPressed: _isLoading ? null : _handleReset,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Send Reset Code', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
