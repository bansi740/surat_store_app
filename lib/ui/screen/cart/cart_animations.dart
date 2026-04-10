import 'package:flutter/material.dart';

class CartAnimations {
  final AnimationController controller;
  final int itemCount;

  late final List<Animation<Offset>> slideAnimations;
  late final List<Animation<double>> fadeAnimations;
  late final Animation<double> checkoutSlide;

  CartAnimations({
    required this.controller,
    required this.itemCount,
  }) {
    slideAnimations = List.generate(itemCount, (index) {
      final start = (index * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.25).clamp(0.0, 1.0);

      return Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    fadeAnimations = List.generate(itemCount, (index) {
      final start = (index * 0.08).clamp(0.0, 0.8);
      final end = (start + 0.25).clamp(0.0, 1.0);

      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    checkoutSlide = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
      ),
    );
  }
}