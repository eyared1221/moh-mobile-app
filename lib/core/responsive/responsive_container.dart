import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'responsive_helper.dart';
import 'responsive_spacing.dart';

/// Responsive container utilities for adaptive layouts.
class ResponsiveContainer {
  /// Get responsive container with max width constraint
  static Widget constrained({
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 600,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }

  /// Get responsive container based on device type
  static Widget adaptive({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveHelper.getDeviceType(context);
        double maxWidth;
        EdgeInsets defaultPadding;

        switch (deviceType) {
          case DeviceType.smallPhone:
            maxWidth = constraints.maxWidth;
            defaultPadding = ResponsiveSpacing.pagePadding(context);
            break;
          case DeviceType.mobile:
            maxWidth = constraints.maxWidth;
            defaultPadding = ResponsiveSpacing.pagePadding(context);
            break;
          case DeviceType.tablet:
            maxWidth = 600;
            defaultPadding = ResponsiveSpacing.symmetricPadding(
              context,
              ResponsiveSpacing.xl,
              ResponsiveSpacing.xl,
            );
            break;
          case DeviceType.largeTablet:
            maxWidth = 800;
            defaultPadding = ResponsiveSpacing.symmetricPadding(
              context,
              ResponsiveSpacing.xl,
              ResponsiveSpacing.xl,
            );
            break;
          case DeviceType.desktop:
            maxWidth = 1200;
            defaultPadding = ResponsiveSpacing.symmetricPadding(
              context,
              ResponsiveSpacing.xxl,
              ResponsiveSpacing.xxl,
            );
            break;
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ?? defaultPadding,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Get responsive card container
  static Widget card({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? borderRadius,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(
          borderRadius ?? ResponsiveSpacing.lgSpacing(context),
        ),
        boxShadow: boxShadow,
      ),
      child: Padding(
        padding: padding ?? ResponsiveSpacing.cardPadding(context),
        child: child,
      ),
    );
  }

  /// Get responsive container with aspect ratio
  static Widget aspectRatio({
    required BuildContext context,
    required double aspectRatio,
    required Widget child,
  }) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: child,
    );
  }

  /// Get responsive container for scrollable content
  static Widget scrollable({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    bool scrollPhysics = true,
  }) {
    return SingleChildScrollView(
      physics: scrollPhysics ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      padding: padding ?? ResponsiveSpacing.pagePadding(context),
      child: child,
    );
  }

  /// Get responsive container with safe area
  static Widget safe({
    required Widget child,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  /// Get responsive container for adaptive layout (mobile vs tablet)
  static Widget adaptiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isDesktop(context) && desktop != null) {
          return desktop;
        }
        if (ResponsiveHelper.isTablet(context) && tablet != null) {
          return tablet;
        }
        return mobile;
      },
    );
  }
}
