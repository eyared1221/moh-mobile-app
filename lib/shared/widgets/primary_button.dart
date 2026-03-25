import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    // explicit text style for label (Poppins Medium 16)
    final labelStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500, // Medium
      color: Theme.of(context).colorScheme.onPrimary,
    );

    final sc = Theme.of(context).shadowColor;
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 8,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Color.fromRGBO(sc.red, sc.green, sc.blue, 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
