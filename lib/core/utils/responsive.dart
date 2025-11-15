import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Helper extensions that keep spacing and typography adaptive across
/// extremely small and very large screen sizes.
extension ResponsiveContext on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);

  Size get screenSize => _mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isLandscape => screenWidth > screenHeight;

  /// Horizontal padding that tightens on phones and expands on tablets.
  double get responsiveHorizontal {
    final width = screenWidth;
    if (width < 340) return 12;
    if (width < 400) return 16;
    if (width < 720) return 22;
    if (width < 1024) return 28;
    return 40;
  }

  /// Vertical padding reacts to short heights to prevent overflow.
  double get responsiveVertical {
    final height = screenHeight;
    if (height < 640) return 12;
    if (height < 740) return 16;
    if (height < 900) return 20;
    return 28;
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: responsiveHorizontal,
        vertical: responsiveVertical,
      );

  /// Clamp any numeric value between compact/regular/expanded ranges.
  double responsiveValue(double compact, double regular, [double? expanded]) {
    final width = screenWidth;
    if (width < 360) return compact;
    if (width > 1100) {
      return expanded ?? regular;
    }
    return regular;
  }

  /// Scale text slightly so it remains legible on the extremes.
  double scaleFont(double base) {
    final width = screenWidth;
    final factor = width < 360
        ? 0.9
        : width > 1200
            ? 1.12
            : 1.0;
    return base * factor;
  }

  /// Maximum width for centered content such as cards or forms.
  double constrainedWidth([double maxWidth = 560]) {
    return math.min(screenWidth - responsiveHorizontal * 2, maxWidth);
  }
}
