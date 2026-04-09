import 'package:flutter/material.dart';

class ProfileAnimations {
  final AnimationController controller;

  late Animation<Offset> headerSlide;
  late Animation<double> headerFade;
  late Animation<double> headerScale;

  final List<Animation<Offset>> optionSlides = [];
  final List<Animation<double>> optionFades = [];

  ProfileAnimations({
    required this.controller,
    required int itemCount,
  }) {
    // Header card animation
    headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.0,
          0.30,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    headerFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.0,
          0.30,
          curve: Curves.easeIn,
        ),
      ),
    );

    headerScale = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // Profile options staggered animation
    for (int i = 0; i < itemCount; i++) {
      final start = 0.30 + i * 0.10;
      final end = start + 0.25;

      optionSlides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.20),
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
        ),
      );

      optionFades.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              start,
              end,
              curve: Curves.easeIn,
            ),
          ),
        ),
      );
    }
  }
}