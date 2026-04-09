import 'package:flutter/material.dart';

class BuyScreenAnimations {
  static Widget fadeSlide({
    required Widget child,
    required AnimationController controller,
    double beginY = 0.2,
    double delay = 0.0,
  }) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final offsetY = (1 - animation.value) * 40 * beginY;

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: child,
          ),
        );
      },
    );
  }
}