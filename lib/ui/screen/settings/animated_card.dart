import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final int index;
  final Widget child;
  final AnimationController controller;

  const AnimatedCard({
    super.key,
    required this.index,
    required this.child,
    required this.controller,
  });

  static const double baseDelay = 0.08;
  static const double stepDelay = 0.10;
  static const double duration = 0.30;

  @override
  Widget build(BuildContext context) {
    final start = (baseDelay + index * stepDelay).clamp(0.0, 0.9);
    final end = (start + duration).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, childWidget) {
        final value = animation.value;

        return Transform.translate(
          offset: Offset(0, (1 - value) * 18),
          child: Opacity(
            opacity: value,
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}