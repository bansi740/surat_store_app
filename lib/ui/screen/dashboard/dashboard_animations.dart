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
    final timings = [
      [0.00, 0.10], // welcome
      [0.10, 0.20], // overview
      [0.20, 0.30], // today orders
      [0.30, 0.40], // today earnings
      [0.40, 0.50], // stats
      [0.50, 0.58], // quick title
      [0.58, 0.66], // add product
      [0.66, 0.74], // inventory
      [0.74, 0.82], // orders
      [0.82, 0.92], // reports
    ];

    Animation<Offset> slide(int index) => Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          timings[index][0],
          timings[index][1],
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    Animation<double> fade(int index) => Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          timings[index][0],
          timings[index][1],
          curve: Curves.easeOut,
        ),
      ),
    );

    welcomeOffset = slide(0);
    welcomeFade = fade(0);

    overviewOffset = slide(1);
    overviewFade = fade(1);

    todayOrdersOffset = slide(2);
    todayOrdersFade = fade(2);

    todayEarningsOffset = slide(3);
    todayEarningsFade = fade(3);

    statsOffset = slide(4);
    statsFade = fade(4);

    quickTitleOffset = slide(5);
    quickTitleFade = fade(5);

    addProductOffset = slide(6);
    addProductFade = fade(6);

    inventoryOffset = slide(7);
    inventoryFade = fade(7);

    ordersOffset = slide(8);
    ordersFade = fade(8);

    reportsOffset = slide(9);
    reportsFade = fade(9);
  }
}