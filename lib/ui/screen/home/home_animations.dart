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
    slideAnimations = [];
    fadeAnimations = [];

    // keep stagger smooth for any product count
    final double staggerGap = itemCount <= 6
        ? 0.10
        : itemCount <= 12
        ? 0.06
        : 0.035;

    for (int i = 0; i < itemCount; i++) {
      final start = (i * staggerGap).clamp(0.0, 0.85);
      final end = (start + 0.22).clamp(0.0, 1.0);

      final curve = CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

      slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.18),
          end: Offset.zero,
        ).animate(curve),
      );

      fadeAnimations.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(curve),
      );
    }
  }
}