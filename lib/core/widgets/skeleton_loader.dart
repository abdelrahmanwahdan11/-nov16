import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key, this.height = 16, this.width = double.infinity, this.borderRadius = 16});

  final double height;
  final double width;
  final double borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: 0.6 + (_controller.value * 0.4),
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment(-1 + _controller.value, -1),
                end: Alignment(1 + _controller.value, 1),
                colors: [
                  theme.colorScheme.surface.withOpacity(0.2),
                  theme.colorScheme.surface.withOpacity(0.5),
                  theme.colorScheme.surface.withOpacity(0.2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
