import 'package:flutter/material.dart';

class InventoryAnimations {
  final AnimationController controller;
  final int itemCount;

  late List<Animation<Offset>> slideAnimations;
  late List<Animation<double>> fadeAnimations;

  InventoryAnimations({
    required this.controller,
    required this.itemCount,
  }) {
    slideAnimations = List.generate(itemCount, (index) {
      final start = index * 0.08;
      final end = start + 0.45;

      return Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    fadeAnimations = List.generate(itemCount, (index) {
      final start = index * 0.08;
      final end = start + 0.45;

      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });
  }
}