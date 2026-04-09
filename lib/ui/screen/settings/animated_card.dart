import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final int index;
  final Widget child;
  final AnimationController controller;

  const AnimatedCard({
    super.key,
    required this.index,
    required this.child,
    required this.controller,
  });

  Animation<Offset> getSlideAnimation() {
    final start = 0.1 + index * 0.1;
    final end = start + 0.3;
    return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<double> getFadeAnimation() {
    final start = 0.1 + index * 0.1;
    final end = start + 0.3;
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: getSlideAnimation(),
      child: FadeTransition(
        opacity: getFadeAnimation(),
        child: child,
      ),
    );
  }
}