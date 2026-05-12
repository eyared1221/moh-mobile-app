import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Responsive spacing utilities for consistent spacing across the app.
/// Based on Material Design 3 spacing scale (4, 8, 12, 16, 24, 32, 48, 64, 96).
class ResponsiveSpacing {
  /// Base spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
  static const double massive = 96;

  /// Get responsive spacing value
  static double getSpacing(
    BuildContext context,
    double baseSpacing, {
    double minScale = 0.8,
    double maxScale = 1.2,
  }) {
    return ResponsiveHelper.responsiveValue(
      context,
      baseSpacing,
      minScale: minScale,
      maxScale: maxScale,
    );
  }

  /// Extra small spacing
  static double xsSpacing(BuildContext context) {
    return getSpacing(context, xs);
  }

  /// Small spacing
  static double smSpacing(BuildContext context) {
    return getSpacing(context, sm);
  }

  /// Medium spacing
  static double mdSpacing(BuildContext context) {
    return getSpacing(context, md);
  }

  /// Large spacing
  static double lgSpacing(BuildContext context) {
    return getSpacing(context, lg);
  }

  /// Extra large spacing
  static double xlSpacing(BuildContext context) {
    return getSpacing(context, xl);
  }

  /// Extra extra large spacing
  static double xxlSpacing(BuildContext context) {
    return getSpacing(context, xxl);
  }

  /// Extra extra extra large spacing
  static double xxxlSpacing(BuildContext context) {
    return getSpacing(context, xxxl);
  }

  /// Huge spacing
  static double hugeSpacing(BuildContext context) {
    return getSpacing(context, huge);
  }

  /// Massive spacing
  static double massiveSpacing(BuildContext context) {
    return getSpacing(context, massive);
  }

  /// Get responsive padding (all sides)
  static EdgeInsets padding(BuildContext context, double value) {
    return EdgeInsets.all(getSpacing(context, value));
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context, double value) {
    return EdgeInsets.symmetric(
      horizontal: getSpacing(context, value),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsets verticalPadding(BuildContext context, double value) {
    return EdgeInsets.symmetric(
      vertical: getSpacing(context, value),
    );
  }

  /// Get responsive symmetric padding
  static EdgeInsets symmetricPadding(
    BuildContext context,
    double horizontal,
    double vertical,
  ) {
    return EdgeInsets.symmetric(
      horizontal: getSpacing(context, horizontal),
      vertical: getSpacing(context, vertical),
    );
  }

  /// Get responsive padding with different values for each side
  static EdgeInsets onlyPadding(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left > 0 ? getSpacing(context, left) : 0,
      top: top > 0 ? getSpacing(context, top) : 0,
      right: right > 0 ? getSpacing(context, right) : 0,
      bottom: bottom > 0 ? getSpacing(context, bottom) : 0,
    );
  }

  /// Get responsive EdgeInsets for card padding
  static EdgeInsets cardPadding(BuildContext context) {
    return EdgeInsets.all(getSpacing(context, lg));
  }

  /// Get responsive EdgeInsets for page padding
  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getSpacing(context, xl),
      vertical: getSpacing(context, lg),
    );
  }

  /// Get responsive EdgeInsets for section padding
  static EdgeInsets sectionPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: getSpacing(context, xl),
    );
  }
}
