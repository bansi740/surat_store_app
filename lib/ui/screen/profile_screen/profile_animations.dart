import 'package:flutter/material.dart';

class ProfileAnimations {
  final AnimationController controller;
  final int itemCount;

  late final Animation<Offset> headerSlide;
  late final Animation<double> headerFade;
  late final Animation<double> headerScale;

  late final List<Animation<Offset>> optionSlides;
  late final List<Animation<double>> optionFades;

  ProfileAnimations({
    required this.controller,
    required this.itemCount,
  }) {
    // shared header curve
    final headerCurve = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.22, curve: Curves.easeOutCubic),
    );

    headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(headerCurve);

    headerFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(headerCurve);

    headerScale = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.24, curve: Curves.easeOutBack),
      ),
    );

    optionSlides = [];
    optionFades = [];

    // dynamic stagger gap
    final double staggerGap = itemCount <= 2 ? 0.12 : 0.08;

    for (int i = 0; i < itemCount; i++) {
      final start = (0.24 + (i * staggerGap)).clamp(0.0, 0.9);
      final end = (start + 0.18).clamp(0.0, 1.0);

      final curve = CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

      optionSlides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).animate(curve),
      );

      optionFades.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(curve),
      );
    }
  }
}