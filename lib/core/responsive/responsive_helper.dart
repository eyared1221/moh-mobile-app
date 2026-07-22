import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Detects device & provides screen info
class ResponsiveHelper {
  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is a small phone
  static bool isSmallPhone(BuildContext context) {
    return width(context) < ResponsiveBreakpoints.smallPhone;
  }

  /// Check if device is a mobile phone
  static bool isMobile(BuildContext context) {
    return width(context) < ResponsiveBreakpoints.mobile;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return width(context) >= ResponsiveBreakpoints.mobile &&
        width(context) < ResponsiveBreakpoints.tablet;
  }

  /// Check if device is a large tablet
  static bool isLargeTablet(BuildContext context) {
    return width(context) >= ResponsiveBreakpoints.tablet &&
        width(context) < ResponsiveBreakpoints.largeTablet;
  }

  /// Check if device is a desktop
  static bool isDesktop(BuildContext context) {
    return width(context) >= ResponsiveBreakpoints.desktop;
  }

  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = width(context);
    if (screenWidth < ResponsiveBreakpoints.smallPhone) {
      return DeviceType.smallPhone;
    } else if (screenWidth < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (screenWidth < ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else if (screenWidth < ResponsiveBreakpoints.largeTablet) {
      return DeviceType.largeTablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if orientation is portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if orientation is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get text scale factor for accessibility
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Get safe area padding
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get max content width based on device type
  static double maxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.smallPhone:
        return width(context);
      case DeviceType.mobile:
        return width(context);
      case DeviceType.tablet:
        return 600;
      case DeviceType.largeTablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }

  /// Calculate responsive value based on screen width
  static double responsiveValue(
    BuildContext context,
    double baseValue, {
    double minScale = 0.8,
    double maxScale = 1.5,
  }) {
    final screenWidth = width(context);
    const baseWidth = 375.0; // Base iPhone width
    final scale = screenWidth / baseWidth;
    return baseValue * scale.clamp(minScale, maxScale);
  }
}
