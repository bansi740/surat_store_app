import 'package:flutter/material.dart';

class HomeAnimations {
  final AnimationController controller;
  final int itemCount;

  late final List<Animation<Offset>> slideAnimations;
  late final List<Animation<double>> fadeAnimations;

  HomeAnimations({
    required this.controller,
    required this.itemCount,
  }) {
    slideAnimations = List.generate(itemCount, (index) {
      final start = (index * 0.08).clamp(0.0, 0.9);
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    fadeAnimations = List.generate(itemCount, (index) {
      final start = (index * 0.08).clamp(0.0, 0.9);
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      );
    });
  }
}