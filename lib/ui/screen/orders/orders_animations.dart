import 'package:flutter/material.dart';

class OrdersAnimations {
  final AnimationController controller;
  final int itemCount;

  OrdersAnimations({
    required this.controller,
    required this.itemCount,
  });

  late final List<Animation<Offset>> slideAnimations = List.generate(
    itemCount,
        (index) {
      final start = (index * 0.06).clamp(0.0, 1.0);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    },
  );

  late final List<Animation<double>> fadeAnimations = List.generate(
    itemCount,
        (index) {
      final start = (index * 0.06).clamp(0.0, 1.0);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    },
  );

  late final List<Animation<double>> scaleAnimations = List.generate(
    itemCount,
        (index) {
      final start = (index * 0.06).clamp(0.0, 1.0);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<double>(
        begin: 0.96,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    },
  );
}