import 'package:flutter/material.dart';

class DashboardAnimations {
  final AnimationController controller;

  // Welcome
  late final Animation<Offset> welcomeOffset;
  late final Animation<double> welcomeFade;

  // Stats
  late final Animation<Offset> statsOffset;
  late final Animation<double> statsFade;

  // Quick Actions Title
  late final Animation<Offset> quickTitleOffset;
  late final Animation<double> quickTitleFade;

  // Quick Action Cards (individual)
  late final Animation<Offset> addProductOffset;
  late final Animation<double> addProductFade;

  late final Animation<Offset> inventoryOffset;
  late final Animation<double> inventoryFade;

  late final Animation<Offset> ordersOffset;
  late final Animation<double> ordersFade;

  late final Animation<Offset> reportsOffset;
  late final Animation<double> reportsFade;

  DashboardAnimations({required this.controller}) {
    // Helper functions for slides and fades
    Animation<Offset> slide(double start, double end) => Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    Animation<double> fade(double start, double end) => Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeIn),
      ),
    );

    // Welcome
    welcomeOffset = slide(0.0, 0.2);
    welcomeFade = fade(0.0, 0.2);

    // Stats
    statsOffset = slide(0.15, 0.35);
    statsFade = fade(0.15, 0.35);

    // Quick Actions Title
    quickTitleOffset = slide(0.3, 0.5);
    quickTitleFade = fade(0.3, 0.5);

    // Quick Action Cards (staggered nicely)
    addProductOffset = slide(0.45, 0.6);
    addProductFade = fade(0.45, 0.6);

    inventoryOffset = slide(0.55, 0.7);
    inventoryFade = fade(0.55, 0.7);

    ordersOffset = slide(0.65, 0.8);
    ordersFade = fade(0.65, 0.8);

    reportsOffset = slide(0.75, 0.9);
    reportsFade = fade(0.75, 0.9);
  }
}