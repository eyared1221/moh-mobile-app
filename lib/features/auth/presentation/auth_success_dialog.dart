import 'package:flutter/material.dart';

enum _AuthFeedbackTone { success, error }

void showAuthSuccessDialog(
  BuildContext context, {
  required String message,
}) {
  _showAuthFeedback(
    context,
    message: message,
    tone: _AuthFeedbackTone.success,
  );
}

void showAuthErrorDialog(
  BuildContext context, {
  required String message,
}) {
  _showAuthFeedback(
    context,
    message: message,
    tone: _AuthFeedbackTone.error,
  );
}

void _showAuthFeedback(
  BuildContext context, {
  required String message,
  required _AuthFeedbackTone tone,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accentColor = tone == _AuthFeedbackTone.success
      ? const Color(0xFF005C8F)
      : const Color(0xFFB85C38);
  final icon = tone == _AuthFeedbackTone.success
      ? Icons.check_rounded
      : Icons.info_outline_rounded;

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      elevation: 0,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101726) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.28 : 0.10),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: accentColor.withOpacity(isDark ? 0.40 : 0.20),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
