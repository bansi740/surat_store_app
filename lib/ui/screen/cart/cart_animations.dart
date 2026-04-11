import 'package:flutter/material.dart';

class CartAnimations {
  final AnimationController controller;
  final int itemCount;

  late final List<Animation<Offset>> slideAnimations;
  late final List<Animation<double>> fadeAnimations;
  late final List<Animation<double>> scaleAnimations;
  late final List<Animation<double>> rotationAnimations;

  late final Animation<double> checkoutSlide;
  late final Animation<double> checkoutFade;
  late final Animation<double> checkoutScale;

  CartAnimations({
    required this.controller,
    required this.itemCount,
  }) {
    slideAnimations = List.generate(itemCount, _buildSlide);
    fadeAnimations = List.generate(itemCount, _buildFade);
    scaleAnimations = List.generate(itemCount, _buildScale);
    rotationAnimations = List.generate(itemCount, _buildRotate);

    checkoutSlide = Tween<double>(
      begin: 60,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    checkoutFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
      ),
    );

    checkoutScale = Tween<double>(
      begin: 0.98,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  // 🎯 ULTRA SMOOTH STAGGER (NO VISUAL STEPS)
  Interval _stagger(int index) {
    if (itemCount <= 1) {
      return const Interval(0.0, 1.0, curve: Curves.easeOutCubic);
    }

    final progress = index / (itemCount - 1);

    // softer distribution curve (ease-in mapping)
    final smoothProgress = Curves.easeInOut.transform(progress);

    final start = 0.06 + (smoothProgress * 0.45);
    final end = (start + 0.32).clamp(0.0, 1.0);

    return Interval(
      start.clamp(0.0, 0.88),
      end,
      curve: Curves.easeOutCubic,
    );
  }

  // 📦 SILKY FLOAT SLIDE (NO SHARP MOVEMENT)
  Animation<Offset> _buildSlide(int index) {
    return Tween<Offset>(
      begin: const Offset(0.0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: _stagger(index),
      ),
    );
  }

  // 🌫 ULTRA SOFT FADE
  Animation<double> _buildFade(int index) {
    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          _stagger(index).begin,
          _stagger(index).end,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  // 🔥 VERY GENTLE SCALE (LUXURY FEEL)
  Animation<double> _buildScale(int index) {
    return Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: _stagger(index),
      ),
    );
  }

  // 🔄 ALMOST ZERO ROTATION (CLEAN PREMIUM UI)
  Animation<double> _buildRotate(int index) {
    return Tween<double>(
      begin: -0.005,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: _stagger(index),
      ),
    );
  }
}