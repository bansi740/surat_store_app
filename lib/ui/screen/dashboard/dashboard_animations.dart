import 'package:flutter/material.dart';

class DashboardAnimations {
  final AnimationController controller;

  late final Animation<Offset> welcomeOffset;
  late final Animation<double> welcomeFade;

  late final Animation<Offset> overviewOffset;
  late final Animation<double> overviewFade;

  late final Animation<Offset> todayOrdersOffset;
  late final Animation<double> todayOrdersFade;

  late final Animation<Offset> todayEarningsOffset;
  late final Animation<double> todayEarningsFade;

  late final Animation<Offset> statsOffset;
  late final Animation<double> statsFade;

  late final Animation<Offset> quickTitleOffset;
  late final Animation<double> quickTitleFade;

  late final Animation<Offset> addProductOffset;
  late final Animation<double> addProductFade;

  late final Animation<Offset> inventoryOffset;
  late final Animation<double> inventoryFade;

  late final Animation<Offset> ordersOffset;
  late final Animation<double> ordersFade;

  late final Animation<Offset> reportsOffset;
  late final Animation<double> reportsFade;

  DashboardAnimations({required this.controller}) {
    Animation<Offset> slide(double start, double end) {
      return Tween<Offset>(
        begin: const Offset(0, 0.16),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    }

    Animation<double> fade(double start, double end) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    }

    welcomeOffset = slide(0.00, 0.10);
    welcomeFade = fade(0.00, 0.10);

    overviewOffset = slide(0.08, 0.20);
    overviewFade = fade(0.08, 0.20);

    todayOrdersOffset = slide(0.18, 0.28);
    todayOrdersFade = fade(0.18, 0.28);

    todayEarningsOffset = slide(0.24, 0.34);
    todayEarningsFade = fade(0.24, 0.34);

    statsOffset = slide(0.32, 0.45);
    statsFade = fade(0.32, 0.45);

    quickTitleOffset = slide(0.42, 0.54);
    quickTitleFade = fade(0.42, 0.54);

    addProductOffset = slide(0.50, 0.62);
    addProductFade = fade(0.50, 0.62);

    inventoryOffset = slide(0.58, 0.70);
    inventoryFade = fade(0.58, 0.70);

    ordersOffset = slide(0.66, 0.78);
    ordersFade = fade(0.66, 0.78);

    reportsOffset = slide(0.74, 0.88);
    reportsFade = fade(0.74, 0.88);
  }
}