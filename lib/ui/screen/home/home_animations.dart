import 'package:flutter/material.dart';

class HomeAnimations {
  final AnimationController controller;
  final int itemCount;

  late final List<Animation<Offset>> slideAnimations;
  late final List<Animation<double>> fadeAnimations;
  late final List<Animation<double>> scaleAnimations;

  HomeAnimations({
    required this.controller,
    required this.itemCount,
  }) {
    slideAnimations = [];
    fadeAnimations = [];
    scaleAnimations = [];

    // smoother stagger distribution
    final double gap = itemCount <= 4
        ? 0.12
        : itemCount <= 10
        ? 0.07
        : 0.045;

    for (int i = 0; i < itemCount; i++) {
      final start = (i * gap).clamp(0.0, 0.82);
      final end = (start + 0.20).clamp(0.0, 1.0);

      final animation = CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

      slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
      );

      fadeAnimations.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
      );

      scaleAnimations.add(
        Tween<double>(
          begin: 0.96,
          end: 1,
        ).animate(animation),
      );
    }
  }
}