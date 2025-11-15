import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/responsive.dart';

typedef AdaptivePageBuilder = Widget Function(
  BuildContext context,
  AdaptivePageData data,
);

class AdaptivePage extends StatelessWidget {
  const AdaptivePage({
    super.key,
    required this.builder,
    this.scrollController,
    this.useSafeArea = true,
    this.centerContent = true,
  });

  final AdaptivePageBuilder builder;
  final ScrollController? scrollController;
  final bool useSafeArea;
  final bool centerContent;

  static AdaptivePageData of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_AdaptivePageScope>();
    assert(scope != null, 'AdaptivePage.of called with no AdaptivePage ancestor');
    return scope!.data;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final bool isCompact = width < 600;
        final bool isMedium = width >= 600 && width < 1024;
        final bool isExpanded = width >= 1024;
        final double paddingHorizontal = context.responsiveHorizontal;
        final double paddingVertical = context.responsiveVertical;
        final padding = EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        );
        final int columns = width >= 1440
            ? 4
            : width >= 1100
                ? 3
                : width >= 720
                    ? 2
                    : 1;
        final double maxWidth = centerContent
            ? (width >= 1400
                ? 1280
                : width >= 1200
                    ? 1120
                    : width >= 1024
                        ? 960
                        : math.min(width, 960))
            : width;
        final data = AdaptivePageData(
          padding: padding,
          maxContentWidth: maxWidth,
          isCompact: isCompact,
          isMedium: isMedium,
          isExpanded: isExpanded,
          gridColumns: columns,
          width: width,
          height: height,
          centerContent: centerContent,
        );
        Widget built = builder(context, data);
        if (scrollController != null) {
          built = PrimaryScrollController(
            controller: scrollController!,
            child: built,
          );
        }
        return _AdaptivePageScope(data: data, child: built);
      },
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}

class AdaptivePageData {
  const AdaptivePageData({
    required this.padding,
    required this.maxContentWidth,
    required this.isCompact,
    required this.isMedium,
    required this.isExpanded,
    required this.gridColumns,
    required this.width,
    required this.height,
    required this.centerContent,
  });

  final EdgeInsets padding;
  final double maxContentWidth;
  final bool isCompact;
  final bool isMedium;
  final bool isExpanded;
  final int gridColumns;
  final double width;
  final double height;
  final bool centerContent;

  double get horizontalPadding => padding.left;
  double get verticalPadding => padding.top;

  Widget wrap(
    Widget child, {
    bool withPadding = true,
    Alignment alignment = Alignment.topCenter,
  }) {
    Widget current = child;
    if (withPadding) {
      current = Padding(padding: padding, child: current);
    }
    if (centerContent && (isMedium || isExpanded)) {
      current = Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: current,
        ),
      );
    }
    return current;
  }

  SliverToBoxAdapter sliver(
    Widget child, {
    bool withPadding = true,
    Alignment alignment = Alignment.topCenter,
  }) {
    return SliverToBoxAdapter(
      child: wrap(child, withPadding: withPadding, alignment: alignment),
    );
  }

  EdgeInsets horizontalInsets([double? value]) {
    return EdgeInsets.symmetric(horizontal: value ?? horizontalPadding);
  }

  EdgeInsets verticalInsets([double? value]) {
    return EdgeInsets.symmetric(vertical: value ?? verticalPadding);
  }
}

class _AdaptivePageScope extends InheritedWidget {
  const _AdaptivePageScope({required this.data, required super.child});

  final AdaptivePageData data;

  @override
  bool updateShouldNotify(covariant _AdaptivePageScope oldWidget) {
    return oldWidget.data != data;
  }
}
