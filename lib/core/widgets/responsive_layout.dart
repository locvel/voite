import 'package:flutter/material.dart';

/// Responsive breakpoints for consistent UI scaling across device sizes.
///
/// - **compact**: Phone portrait, narrow layouts (< 600dp)
/// - **medium**: Large phones landscape, small tablets (600dp - 839dp)
/// - **expanded**: Tablets landscape, desktop (≥ 840dp)
class ResponsiveBreakpoints {
  static const double medium = 600;
  static const double expanded = 840;
}

/// Helper to determine the current responsive breakpoint.
enum ScreenSize { compact, medium, expanded }

extension ResponsiveContext on BuildContext {
  /// Returns the current [ScreenSize] based on the shortest side.
  ScreenSize get screenSize {
    final width = MediaQuery.of(this).size.shortestSide;
    if (width >= ResponsiveBreakpoints.expanded) return ScreenSize.expanded;
    if (width >= ResponsiveBreakpoints.medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  /// True if the screen is medium or larger (tablet/desktop).
  bool get isTablet =>
      MediaQuery.of(this).size.shortestSide >= ResponsiveBreakpoints.medium;

  /// True if the screen is expanded (large tablet/desktop).
  bool get isExpanded =>
      MediaQuery.of(this).size.shortestSide >= ResponsiveBreakpoints.expanded;

  /// Adaptive padding based on screen size.
  double get responsivePadding {
    final size = screenSize;
    switch (size) {
      case ScreenSize.compact:
        return 20;
      case ScreenSize.medium:
        return 32;
      case ScreenSize.expanded:
        return 48;
    }
  }

  /// Grid cross-axis count based on screen size.
  int get gridColumnCount {
    final size = screenSize;
    switch (size) {
      case ScreenSize.compact:
        return 1;
      case ScreenSize.medium:
        return 2;
      case ScreenSize.expanded:
        return 3;
    }
  }
}

/// Adaptive layout builder that switches between compact/medium/expanded layouts.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    switch (size) {
      case ScreenSize.expanded:
        return expanded ?? medium ?? compact;
      case ScreenSize.medium:
        return medium ?? compact;
      case ScreenSize.compact:
        return compact;
    }
  }
}
