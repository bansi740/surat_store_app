import 'package:flutter/material.dart';

class TotalEarningsAnimations {
  final Animation<Offset> slideUp;
  final Animation<double> fade;
  final Animation<double> scale;
  final Animation<double> refreshPulse;

  TotalEarningsAnimations(AnimationController controller)
    : slideUp =
          Tween<Offset>(
            begin: const Offset(0, 0.25), // subtle upward movement
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: const Interval(
                0.0,
                0.5, // slightly faster slide
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
      fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
        ),
      ),
      scale =
          Tween<double>(
            begin: 0.97, // subtle pop effect
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: const Interval(
                0.1, // slight overlap with slide/fade
                0.7,
                curve: Curves.elasticOut, // soft springy effect
              ),
            ),
          ),
      refreshPulse = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
}
