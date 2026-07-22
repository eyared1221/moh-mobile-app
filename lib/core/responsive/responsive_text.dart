import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Responsive typography utilities for consistent text sizing across the app.
/// Based on Material Design 3 typography scale.
class ResponsiveText {
  static const double displayLarge = 57;
  static const double displayMedium = 45;
  static const double displaySmall = 36;
  static const double headlineLarge = 32;
  static const double headlineMedium = 28;
  static const double headlineSmall = 24;
  static const double titleLarge = 22;
  static const double titleMedium = 16;
  static const double titleSmall = 14;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 11;

  /// Get responsive font size
  static double getFontSize(
    BuildContext context,
    double baseFontSize, {
    double minScale = 0.85,
    double maxScale = 1.15,
  }) {
    final screenWidth = ResponsiveHelper.width(context);
    const baseWidth = 375.0; // Base iPhone width
    final scale = screenWidth / baseWidth;
    return baseFontSize * scale.clamp(minScale, maxScale);
  }

  /// Display large text
  static double displayLargeSize(BuildContext context) {
    return getFontSize(context, displayLarge);
  }

  /// Display medium text
  static double displayMediumSize(BuildContext context) {
    return getFontSize(context, displayMedium);
  }

  /// Display small text
  static double displaySmallSize(BuildContext context) {
    return getFontSize(context, displaySmall);
  }

  /// Headline large text
  static double headlineLargeSize(BuildContext context) {
    return getFontSize(context, headlineLarge);
  }

  /// Headline medium text
  static double headlineMediumSize(BuildContext context) {
    return getFontSize(context, headlineMedium);
  }

  /// Headline small text
  static double headlineSmallSize(BuildContext context) {
    return getFontSize(context, headlineSmall);
  }

  /// Title large text
  static double titleLargeSize(BuildContext context) {
    return getFontSize(context, titleLarge);
  }

  /// Title medium text
  static double titleMediumSize(BuildContext context) {
    return getFontSize(context, titleMedium);
  }

  /// Title small text
  static double titleSmallSize(BuildContext context) {
    return getFontSize(context, titleSmall);
  }

  /// Body large text
  static double bodyLargeSize(BuildContext context) {
    return getFontSize(context, bodyLarge);
  }

  /// Body medium text
  static double bodyMediumSize(BuildContext context) {
    return getFontSize(context, bodyMedium);
  }

  /// Body small text
  static double bodySmallSize(BuildContext context) {
    return getFontSize(context, bodySmall);
  }

  /// Label large text
  static double labelLargeSize(BuildContext context) {
    return getFontSize(context, labelLarge);
  }

  /// Label medium text
  static double labelMediumSize(BuildContext context) {
    return getFontSize(context, labelMedium);
  }

  /// Label small text
  static double labelSmallSize(BuildContext context) {
    return getFontSize(context, labelSmall);
  }

  /// Get responsive TextStyle
  static TextStyle getStyle(
    BuildContext context,
    double fontSize, {
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: getFontSize(context, fontSize),
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Get responsive headline style
  static TextStyle headlineStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return getStyle(
      context,
      headlineMedium,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
    );
  }

  /// Get responsive title style
  static TextStyle titleStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return getStyle(
      context,
      titleLarge,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w600,
    );
  }

  /// Get responsive body style
  static TextStyle bodyStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return getStyle(
      context,
      bodyMedium,
      color: color,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  /// Get responsive caption style
  static TextStyle captionStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return getStyle(
      context,
      bodySmall,
      color: color,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  /// Get responsive button text style
  static TextStyle buttonStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return getStyle(
      context,
      labelLarge,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w600,
    );
  }
}
