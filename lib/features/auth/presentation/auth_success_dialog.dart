import 'package:flutter/material.dart';

void showAuthSuccessDialog(
  BuildContext context, {
  required String message,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  const primaryColor = Color(0xFF005C8F);

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      elevation: 0,
      duration: const Duration(seconds: 2),
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
            color: primaryColor.withOpacity(isDark ? 0.40 : 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(isDark ? 0.22 : 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: primaryColor,
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
