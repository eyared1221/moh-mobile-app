/// Centralized breakpoint definitions for responsive design.
/// Based on Material Design 3 breakpoint system.
class ResponsiveBreakpoints {
  /// Small phones (less than 360px width)
  static const double smallPhone = 360;

  /// Normal phones (360px to 600px)
  static const double mobile = 600;

  /// Tablets (600px to 900px)
  static const double tablet = 900;

  /// Large tablets (900px to 1200px)
  static const double largeTablet = 1200;

  /// Desktop (greater than 1200px)
  static const double desktop = 1200;
}

/// Device type enum for easy device identification
enum DeviceType {
  smallPhone,
  mobile,
  tablet,
  largeTablet,
  desktop,
}
