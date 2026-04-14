import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/order_controller.dart';
import '../../../data/model/order_model.dart';
import 'cart_animations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  final cartController = Get.find<CartController>();
  final orderController = Get.find<OrderController>();

  final TextEditingController nameController = TextEditingController();

  final Color primaryBlue = const Color(0xff2563EB);

  // Button disabled by default
  final RxString nameError = "Name is required".obs;

  final double gstPercent = 5.0;

  double get gstAmount => cartController.totalPrice * gstPercent / 100;

  double get grandTotal => cartController.totalPrice + gstAmount;
  // animation for add to cart item enters
  late AnimationController _animationController;

  Timer? _holdTimer;
  void _startQtyHold({
    required bool isIncrement,
    required CartItem cartItem,
  }) {
    _changeQty(cartItem: cartItem, isIncrement: isIncrement);

    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _changeQty(cartItem: cartItem, isIncrement: isIncrement);
    });
  }

  void _stopQtyHold() {
    _holdTimer?.cancel();
  }

  void _changeQty({
    required CartItem cartItem,
    required bool isIncrement,
  }) {
    if (!mounted) return;

    if (isIncrement) {
      if (cartItem.qty.value < cartItem.product.stockQty) {
        cartController.increaseQty(cartItem);
      }
    } else {
      if (cartItem.qty.value > 1) {
        cartController.decreaseQty(cartItem);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void validateName(String value) {
    final name = value.trim();

    if (name.isEmpty) {
      nameError.value = "Name is required";
    } else if (name.length < 3) {
      nameError.value = "Minimum 3 characters required";
    } else {
      nameError.value = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff2563EB), Color(0xff1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () async {
                if (cartController.cartItems.isEmpty) {
                  Get.snackbar(
                    "Cart Empty",
                    "No items to remove",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                final confirm = await Get.dialog<bool>(
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Warning Icon
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withAlpha(20),
                            ),
                            child: const Icon(
                              Icons.delete_sweep_rounded,
                              size: 34,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Title
                          const Text(
                            "Clear Cart?",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Subtitle
                          Text(
                            "This will permanently remove all cart items from your shopping list.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(result: false),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Get.back(result: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    "Clear",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (confirm == true) {
                  await cartController.clearCart();

                  Get.snackbar(
                    "Success",
                    "All cart items removed",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(30),
                  border: Border.all(
                    color: Colors.white.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_sweep,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // empty cart
        if (cartController.cartItems.isEmpty) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xff2563EB).withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 42,
                      color: Color(0xff2563EB),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    "Your Cart is Empty",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Looks like you haven’t added anything yet.\nStart shopping to fill your cart.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        }
        final animations = CartAnimations(
          controller: _animationController,
          itemCount: cartController.cartItems.length,
        );
        return Stack(
          children: [
            // ================= CART ITEMS =================
            Padding(
              padding: const EdgeInsets.only(bottom: 300),
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartController.cartItems[index];

                  return SlideTransition(
                    //this for enters animation
                    position: animations.slideAnimations[index],
                    child: FadeTransition(
                      opacity: animations.fadeAnimations[index],
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryBlue.withAlpha(25),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: primaryBlue.withAlpha(35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withAlpha(12),
                              blurRadius: 18,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // LEFT IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: cartItem.product.imagePath.isNotEmpty
                                  ? Image.file(
                                      File(cartItem.product.imagePath),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TOP ROW
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cartItem.product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      GestureDetector(
                                        onTap: () => cartController
                                            .removeFromCart(cartItem),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withAlpha(25),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.red.withAlpha(35),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // BOTTOM ROW
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "₹${cartItem.product.price}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _qtyButton(
                                            icon: Icons.remove,
                                            cartItem: cartItem,
                                            enabled: cartItem.qty.value > 1,
                                            isIncrement: false,
                                          ),

                                          const SizedBox(width: 8),

                                          Obx(
                                            () => Text(
                                              "${cartItem.qty.value}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff2563EB),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          _qtyButton(
                                            icon: Icons.add,
                                            cartItem: cartItem,
                                            enabled: cartItem.qty.value < cartItem.product.stockQty,
                                            isIncrement: true,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // ================= BOTTOM CHECKOUT =================
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 75, // ✅ space for bottom navigation
                  ),
                  height: 300,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: primaryBlue.withAlpha(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withAlpha(12),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // NAME FIELD
                      TextFormField(
                        controller: nameController,
                        onChanged: validateName,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: "Enter Customer Name",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                
                          // Beautiful prefix icon
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xff2563EB).withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xff2563EB),
                            ),
                          ),
                
                          // Default border
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                
                          // Enabled border
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                
                          // Focus border
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xff2563EB),
                              width: 1,
                            ),
                          ),
                
                          // Error border
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                
                          errorText: nameError.value.isEmpty
                              ? null
                              : nameError.value,
                        ),
                      ),
                
                      const SizedBox(height: 12),
                      // PRODUCT SUMMARY
                      Expanded(
                        child: ListView(
                          children: cartController.cartItems
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${c.product.name} x ${c.qty.value}"),
                                      Text("₹${c.product.price * c.qty.value}"),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const Divider(),
                      // GST
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("GST ($gstPercent%)"),
                          Text("₹${gstAmount.toStringAsFixed(2)}"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // GRAND TOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Grand Total",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${grandTotal.toStringAsFixed(2)}",
                            style: TextStyle(fontWeight: FontWeight.bold,color: primaryBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // CHECKOUT BUTTON
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: nameError.value.isNotEmpty
                                ? null
                                : () async {
                                    final customerName = nameController.text
                                        .trim();
                
                                    if (customerName.isEmpty ||
                                        customerName.length < 3) {
                                      nameError.value = "Please enter valid name";
                                      return;
                                    }
                
                                    bool outOfStock = false;
                
                                    for (var item in cartController.cartItems) {
                                      if (item.qty.value >
                                          item.product.stockQty) {
                                        outOfStock = true;
                                        Get.snackbar(
                                          "Error",
                                          "${item.product.name} does not have enough stock",
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        break;
                                      }
                                    }
                
                                    if (outOfStock) {
                                      return;
                                    }
                
                                    final order = OrderModel(
                                      totalAmount: grandTotal,
                                      orderDate: DateTime.now(),
                                      customerName: customerName,
                                    );
                
                                    final items = cartController.cartItems
                                        .map(
                                          (c) => {
                                            "product_id": c.product.pId,
                                            "qty_sold": c.qty.value,
                                            "price": c.product.price,
                                            "name": c.product.name,
                                          },
                                        )
                                        .toList();
                
                                    await orderController.addOrderWithItems(
                                      order: order,
                                      items: items,
                                    );
                
                                    for (var c in cartController.cartItems) {
                                      final newStock =
                                          c.product.stockQty - c.qty.value;
                
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(AuthController.to.currentShopId)
                                          .collection('products')
                                          .doc(c.product.pId)
                                          .update({'stockQty': newStock});
                                    }
                                    cartController.clearCart();
                                    nameController.clear();
                                    if (mounted) {
                                      nameController.clear();
                                      nameError.value = "Name is required";
                                    }
                
                                    _showModernDialog(
                                      title: "Order Successful",
                                      message:
                                          "Your order has been placed successfully.\nThank you for shopping with us.",
                                      buttonColor: const Color(0xff2563EB),
                                      buttonText: "Done",
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Get.back();
                                      },
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.all(14),
                            ),
                            child: const Text(
                              "Checkout",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // qty button
  Widget _qtyButton({
    required IconData icon,
    required CartItem cartItem,
    required bool enabled,
    required bool isIncrement,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        // ✅ single tap
        onTap: enabled
            ? () => _changeQty(
          cartItem: cartItem,
          isIncrement: isIncrement,
        )
            : null,

        // ✅ long press start
        onLongPressStart: enabled
            ? (_) => _startQtyHold(
          isIncrement: isIncrement,
          cartItem: cartItem,
        )
            : null,

        // ✅ long press stop
        onLongPressEnd: enabled ? (_) => _stopQtyHold() : null,

        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xffF1F5F9)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? const Color(0xff2563EB)
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  // checkout message
  Future<void> _showModernDialog({
    required String title,
    required String message,
    required Color buttonColor,
    required String buttonText,
    VoidCallback? onPressed,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 15,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200.withAlpha(30),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 40, color: Colors.white),
                ),

                const SizedBox(height: 20),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff475569),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
