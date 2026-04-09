import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color primaryBlue = const Color(0xff2563EB);
  bool animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => animate = true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: animate ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            offset: animate ? Offset.zero : const Offset(0, 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 700),
                  tween: Tween(begin: 0.85, end: animate ? 1 : 0.85),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: primaryBlue.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_checkout_rounded,
                      size: 42,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Your Cart is Empty",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Looks like you haven’t added\nany products yet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
