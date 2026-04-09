import 'package:flutter/material.dart';

class AddProductAnimations {
  final AnimationController controller;

  late final Animation<Offset> imagePickerSlide;
  late final Animation<double> imagePickerFade;

  late final Animation<Offset> formSlide;
  late final Animation<double> formFade;

  late final Animation<Offset> buttonSlide;
  late final Animation<double> buttonFade;

  late final Animation<Offset> imagePreviewSlide;
  late final Animation<double> imagePreviewFade;


  AddProductAnimations({required this.controller}) {
    imagePickerSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    imagePickerFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.35),
      ),
    );

    formSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
      ),
    );

    formFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.25, 0.7),
      ),
    );

    buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    buttonFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.6, 1.0),
      ),
    );

    imagePreviewSlide = Tween<Offset>(
      begin: const Offset(0, -0.3), // start slightly above
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    imagePreviewFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
  }
}