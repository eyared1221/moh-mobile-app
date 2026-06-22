import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_success_dialog.dart';
import 'auth_error_handler.dart';
import 'auth_messages.dart';
import 'signin_screen.dart';
import '../data/auth_api_client.dart';
import '../data/auth_models.dart';
import 'controllers/auth_controller.dart';

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
  bool _isTelegramLinked = false;
  bool _isCheckingTelegram = false;
  bool _isLaunchingTelegram = false;
  final AuthController _authController = AuthController.standard();
  final AuthApiClient _apiClient = AuthApiClient();

  bool get _isEmailContact => widget.contact.contains('@');
  bool get _isPhoneContact => !_isEmailContact;

  @override
  void initState() {
    super.initState();
    if (_isPhoneContact) {
      _checkTelegramLinkStatus();
    }
  }

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
    if (_isPhoneContact && !_isTelegramLinked) {
      showAuthErrorDialog(
        context,
        message: 'Please connect Telegram to receive your verification code.',
      );
      return;
    }
    if (_verificationCode.length != 6) {
      setState(() => _showCodeError = true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _authController.verifyOtp(
        contact: widget.contact,
        otp: _verificationCode,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      showAuthSuccessDialog(
        context,
        message: _isEmailContact
            ? AuthMessages.emailVerifiedSuccess
            : AuthMessages.phoneVerifiedSuccess,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SignInScreen(language: widget.language)),
        (route) => false,
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

  void _handleResend() async {
    try {
      if (_isPhoneContact && !_isTelegramLinked) {
        showAuthErrorDialog(
          context,
          message: 'Please connect Telegram to receive your verification code.',
        );
        return;
      }
      final result = await _authController.resendOtp(contact: widget.contact);
      if (!mounted) return;
      showAuthSuccessDialog(
        context,
        message: result.debugCode == null
            ? 'A new verification code was sent to ${widget.contact}.'
            : 'A new verification code was generated for ${widget.contact}. Use ${result.debugCode}.',
      );
    } catch (error) {
      if (!mounted) return;
      showAuthErrorDialog(
        context,
        message: AuthErrorHandler.getMessage(error),
      );
    }
  }

  Future<void> _checkTelegramLinkStatus() async {
    if (_isCheckingTelegram) return;
    setState(() => _isCheckingTelegram = true);

    try {
      print('DEBUG: Checking Telegram link status for contact: ${widget.contact}');
      final payload = await _apiClient.post('/telegram?action=status', {
        'contact': widget.contact,
      });
      print('DEBUG: Telegram status response: $payload');

      final data = payload['data'] as Map<String, dynamic>? ?? const {};
      final linked = data['linked'] == true;
      print('DEBUG: Telegram linked status: $linked');

      if (!mounted) return;
      setState(() {
        _isTelegramLinked = linked;
        _isCheckingTelegram = false;
      });
    } catch (error) {
      print('DEBUG: Telegram status check error: $error');
      print('DEBUG: Error type: ${error.runtimeType}');
      if (!mounted) return;
      setState(() => _isCheckingTelegram = false);
    }
  }

  Future<void> _connectTelegram() async {
    if (_isLaunchingTelegram) return;

    setState(() => _isLaunchingTelegram = true);
    try {
      print('DEBUG: Connecting Telegram for contact: ${widget.contact}');
      final payload = await _apiClient.post('/telegram?action=start-link', {
        'contact': widget.contact,
      });
      print('DEBUG: Telegram link response: $payload');
      final data = payload['data'] as Map<String, dynamic>? ?? const {};
      final url = data['telegramBotUrl'] as String?;

      if (url == null || url.trim().isEmpty) {
        print('DEBUG: No telegramBotUrl in response');
        throw const AuthApiException('Unable to create Telegram link.');
      }

      print('DEBUG: Telegram bot URL: $url');
      _showOpeningTelegramMessage();
      final launched = await _launchTelegramBotUrl(url);
      if (!launched) {
        if (!mounted) return;
        await _showTelegramLinkDialog(url);
        return;
      }

      if (!mounted) return;
      setState(() => _isLaunchingTelegram = false);

      // Poll briefly for Telegram linking (user returns to app after pressing Start).
      for (var i = 0; i < 15; i++) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        await _checkTelegramLinkStatus();
        if (_isTelegramLinked) {
          return;
        }
      }
    } catch (error) {
      print('DEBUG: Telegram connection error: $error');
      print('DEBUG: Error type: ${error.runtimeType}');
      if (!mounted) return;
      setState(() => _isLaunchingTelegram = false);
      showAuthErrorDialog(
        context,
        message: AuthErrorHandler.getMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLaunchingTelegram = false);
      }
    }
  }

  void _showOpeningTelegramMessage() {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Opening Telegram...'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<bool> _launchTelegramBotUrl(String botUrl) async {
    final uri = Uri.parse(botUrl);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showTelegramLinkDialog(String telegramLink) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Open Telegram Manually'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Telegram could not be opened automatically. Use this link to open the bot and press Start.',
              ),
              const SizedBox(height: 12),
              SelectableText(telegramLink),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: telegramLink));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Telegram link copied'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Copy Link'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTelegramHint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF005C8F);
    final cardColor = isDark ? const Color(0xFF161D2C) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final iconBg = isDark ? const Color(0xFF0E2233) : const Color(0xFFE6F4FF);
    final iconColor = isDark ? const Color(0xFF74C0FF) : primaryColor;
    final headerText = _isTelegramLinked
        ? 'We sent it to ${widget.contact} in Telegram'
        : 'Open our Telegram bot and press Start to receive your OTP.';
    final titleText = _isTelegramLinked ? 'Check Telegram' : 'Connect Telegram';
    final bodyText = _isTelegramLinked
        ? 'The code is in the Verification Codes chat'
        : 'Open our Telegram bot and press Start to receive your OTP.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          headerText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bodyText,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
                    child: Image.asset(
                      'assets/images/verify-email-removebg-preview.png',
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isEmailContact ? 'Verify Your Email' : 'Verify Your Phone',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                   const SizedBox(height: 10),
                   if (_isEmailContact) ...[
                     Text(
                       'We''ve sent a 6-digit code to ${widget.contact}. Enter it below to complete your sign up.',
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         fontSize: 14,
                         color: isDark ? Colors.grey[400] : Colors.grey[600],
                       ),
                     ),
                     const SizedBox(height: 28),
                   ] else ...[
                     _buildTelegramHint(context),
                     const SizedBox(height: 20),
                     SizedBox(
                       width: double.infinity,
                       height: 52,
                       child: ElevatedButton.icon(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: primaryColor,
                           foregroundColor: Colors.white,
                           elevation: 4,
                           shadowColor: primaryColor.withOpacity(0.4),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         ),
                         onPressed: (_isLaunchingTelegram || _isCheckingTelegram)
                             ? null
                             : (_isTelegramLinked ? null : _connectTelegram),
                         icon: _isLaunchingTelegram || _isCheckingTelegram
                             ? SizedBox(
                                 width: 18,
                                 height: 18,
                                 child: CircularProgressIndicator(
                                   color: Colors.white,
                                   strokeWidth: 2,
                                 ),
                               )
                             : const Icon(Icons.link_rounded),
                         label: Text(
                           _isTelegramLinked ? 'Telegram Connected' : 'Connect Telegram',
                           style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                         ),
                       ),
                     ),
                     const SizedBox(height: 22),
                   ],
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
                     children: List.generate(
                       6,
                       (index) => AbsorbPointer(
                         absorbing: _isPhoneContact && !_isTelegramLinked,
                         child: Opacity(
                           opacity: _isPhoneContact && !_isTelegramLinked ? 0.45 : 1,
                           child: _buildCodeBox(context, index),
                         ),
                       ),
                     ),
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
                    height: 52,
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
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _isEmailContact ? 'Verify Email' : 'Verify Phone',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
