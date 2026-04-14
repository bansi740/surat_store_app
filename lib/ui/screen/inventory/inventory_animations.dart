import 'package:flutter/material.dart';

class InventoryAnimations {
  final AnimationController controller;
  final int itemCount;

  late final List<Animation<Offset>> slideAnimations;
  late final List<Animation<double>> fadeAnimations;
  late final List<Animation<double>> scaleAnimations;

  InventoryAnimations({
    required this.controller,
    required this.itemCount,
  }) {
    // Dynamic stagger for smooth large lists
    final double stagger = itemCount <= 5
        ? 0.12
        : itemCount <= 10
        ? 0.07
        : 0.04;

    slideAnimations = List.generate(itemCount, (index) {
      final start = (index * stagger).clamp(0.0, 0.85);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            start,
            end,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    fadeAnimations = List.generate(itemCount, (index) {
      final start = (index * stagger).clamp(0.0, 0.85);
      final end = (start + 0.30).clamp(0.0, 1.0);

      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            start,
            end,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    scaleAnimations = List.generate(itemCount, (index) {
      final start = (index * stagger).clamp(0.0, 0.85);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<double>(
        begin: 0.96,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            start,
            end,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
  }
}