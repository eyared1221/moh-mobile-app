import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signin_screen.dart';
import 'auth_success_dialog.dart';
import '../data/auth_models.dart';
import '../data/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? language;
  final String contact;
  final String userName;
  final int age;
  final String? debugCode;

  const VerifyEmailScreen({
    super.key,
    this.language,
    required this.contact,
    required this.userName,
    required this.age,
    this.debugCode,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _digitControllers = List.generate(6, (_) => TextEditingController());
  final _digitFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _showCodeError = false;
  final AuthService _authService = AuthService.instance;

  bool get _isEmailContact => widget.contact.contains('@');

  @override
  void dispose() {
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final focusNode in _digitFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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

  String get _verificationCode {
    return _digitControllers.map((controller) => controller.text).join();
  }

  void _onCodeChanged(int index, String value) {
    if (_showCodeError) {
      setState(() => _showCodeError = false);
    }

    if (value.isNotEmpty && index < _digitFocusNodes.length - 1) {
      _digitFocusNodes[index + 1].requestFocus();
      return;
    }

    if (value.isEmpty && index > 0) {
      _digitFocusNodes[index - 1].requestFocus();
    }
  }

  Widget _buildCodeBox(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF005C8F);

    return SizedBox(
      width: 48,
      child: TextField(
        controller: _digitControllers[index],
        focusNode: _digitFocusNodes[index],
        keyboardType: TextInputType.number,
        textInputAction: index == _digitControllers.length - 1 ? TextInputAction.done : TextInputAction.next,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? const Color(0xFF161D2C) : const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
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
        ),
        onChanged: (value) => _onCodeChanged(index, value),
        onSubmitted: (_) {
          if (index == _digitControllers.length - 1 && !_isLoading) {
            _handleVerify();
          }
        },
      ),
    );
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;
    if (_verificationCode.length != 6) {
      setState(() => _showCodeError = true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _authService.verifyOtp(
        contact: widget.contact,
        otp: _verificationCode,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      showAuthSuccessDialog(
        context,
        message: _isEmailContact
            ? 'Your email has been verified successfully.'
            : 'Your phone number has been verified successfully.',
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SignInScreen(language: widget.language)),
        (route) => false,
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
        message: _isEmailContact
            ? 'Failed to verify email. Please try again.'
            : 'Failed to verify phone number. Please try again.',
      );
    }
  }

  void _handleResend() async {
    try {
      final result = await _authService.resendOtp(contact: widget.contact);
      if (!mounted) return;
      showAuthSuccessDialog(
        context,
        message: result.debugCode == null
            ? 'A new verification code was sent to ${widget.contact}.'
            : 'A new verification code was generated for ${widget.contact}. Use ${result.debugCode}.',
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      showAuthErrorDialog(context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      showAuthErrorDialog(
        context,
        message: 'Failed to resend code. Please try again.',
      );
    }
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
                    child: Image.asset(
                      'assets/images/email-verify.png',
                      height: 168,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 88,
                          height: 88,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(isDark ? 0.18 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            size: 42,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isEmailContact ? 'Verify Your Email' : 'Verify Your Phone',
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
                    _isEmailContact
                        ? 'We''ve sent a 6-digit code to ${widget.contact}. Enter it below to complete your sign up.'
                        : 'Enter the 6-digit code for ${widget.contact} to complete your sign up.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (widget.debugCode != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        'Use this code: ${widget.debugCode}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Enter 6-digit code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => _buildCodeBox(context, index)),
                  ),
                  if (_showCodeError) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Enter the 6-digit code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.redAccent.shade200,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
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
                      onPressed: _isLoading ? null : _handleVerify,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _isEmailContact ? 'Verify Email' : 'Verify Phone',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: _handleResend,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
