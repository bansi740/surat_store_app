import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/utils/app_formatter.dart';
import '../../../core/utils/assets.dart';
import '../../../data/model/product_model.dart';
import '../../../controllers/order_controller.dart';
import '../../../data/model/order_model.dart';

class BuyScreen extends StatefulWidget {
  final ProductModel product;

  const BuyScreen({super.key, required this.product});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final OrderController orderController = Get.put(OrderController());
  final ProductController productController = Get.find<ProductController>();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int quantity = 1;
  Timer? _holdTimer;
  final double gstPercent = 5.0;
  final Color primaryBlue = const Color(0xff2563EB);
  final Color primaryGreen = const Color(0xff16A34A);

  // long to add quantity
  void _startHold(bool isIncrement) {
    _changeQuantity(isIncrement); // instant first change

    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _changeQuantity(isIncrement);
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
  }

  void _changeQuantity(bool isIncrement) {
    if (!mounted) return;
    if (widget.product.stockQty == 0) return;

    setState(() {
      if (isIncrement) {
        if (quantity < widget.product.stockQty) {
          quantity++;
        }
      } else {
        if (quantity > 1) {
          quantity--;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  double get subtotal => widget.product.price * quantity;

  double get gstAmount => subtotal * gstPercent / 100;

  double get total => subtotal + gstAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        automaticallyImplyActions: false,
        centerTitle: true,
        title: Text(
          "Buy ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        backgroundColor: primaryBlue,
        surfaceTintColor: primaryBlue,
        leading: IconButton(
          onPressed: () {
            Get.back();
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
              border: Border.all(color: Colors.white.withAlpha(50), width: 1),
            ),
            child: Center(
              child: Image.asset(
                AppAssets.backIcon,
                width: 22,
                height: 22,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xff2563EB).withAlpha(40),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: widget.product.imagePath.isNotEmpty &&
                          File(widget.product.imagePath).existsSync()
                          ? Image.file(
                        File(widget.product.imagePath),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xff2563EB).withAlpha(10),
                              const Color(0xff2563EB).withAlpha(25),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 72,
                                color: const Color(0xff2563EB).withAlpha(160),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Product Name
                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withAlpha(230),
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  widget.product.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: Colors.grey.withAlpha(200),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 14),

                // ===== INFO ROW (Stock + Price + Label) =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // STOCK BADGE (LEFT)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.product.stockQty > 5
                            ? Colors.green.withAlpha(12)
                            : Colors.red.withAlpha(12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.product.stockQty > 5
                              ? Colors.green.withAlpha(25)
                              : Colors.red.withAlpha(25),
                        ),
                      ),
                      child: Text(
                        "Stock ${widget.product.stockQty}",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: widget.product.stockQty > 5
                              ? Colors.green.withAlpha(220)
                              : Colors.red.withAlpha(220),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // PRICE (INLINE RIGHT SIDE - NOT STACKED)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563EB).withAlpha(12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xff2563EB).withAlpha(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Price: ₹",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff2563EB).withAlpha(220),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.price.toString(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xff2563EB).withAlpha(220),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quantity Selector
                _buildQuantitySelector(),

                const SizedBox(height: 20),

                // Billing Card
                _buildBillingCard(),

                const SizedBox(height: 20),

                Text(
                  "Customer Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                // Name Input with auto validation
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff111827),
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter Customer Name",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white.withAlpha(245),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),

                    prefixIcon: Container(
                      margin: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryBlue.withAlpha(22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryBlue.withAlpha(35)),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: primaryBlue,
                        size: 22,
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300.withAlpha(180),
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: primaryBlue, width: 1),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.red.withAlpha(180),
                        width: 1,
                      ),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.red.withAlpha(220),
                        width: 1,
                      ),
                    ),

                    errorStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),

                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.isEmpty) {
                      return "Name is required";
                    } else if (name.length < 3) {
                      return "Minimum 3 characters required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Confirm Purchase Button
                Row(
                  children: [
                    // Small Cancel Button
                    SizedBox(
                      width: 100, // Small fixed width
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey.shade800,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm Purchase Button - takes remaining space
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: widget.product.stockQty == 0
                              ? null
                              : _confirmPurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.product.stockQty == 0
                                ? Colors.grey.shade400
                                : primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            widget.product.stockQty == 0
                                ? "Out of Stock"
                                : "Confirm Purchase",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern Quantity Selector
  Widget _buildQuantitySelector() {
    final bool outOfStock = widget.product.stockQty == 0;
    final bool canDecrease = !outOfStock && quantity > 1;
    final bool canIncrease = !outOfStock && quantity < widget.product.stockQty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(245),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200.withAlpha(160)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(
            "Quantity",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black.withAlpha(200),
              letterSpacing: 0.2,
            ),
          ),

          // Counter controls
          Row(
            children: [
              _quantityButton(
                icon: Icons.remove,
                enabled: canDecrease,
                isIncrement: false,
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryBlue.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue.withAlpha(20)),
                ),
                child: Text(
                  outOfStock ? "0" : quantity.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              _quantityButton(
                icon: Icons.add,
                enabled: canIncrease,
                isIncrement: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required bool isIncrement,
  }) {
    return GestureDetector(
      onTapDown: enabled ? (_) => _startHold(isIncrement) : null,
      onTapUp: enabled ? (_) => _stopHold() : null,
      onTapCancel: enabled ? _stopHold : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? primaryBlue.withAlpha(14)
              : Colors.grey.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? primaryBlue.withAlpha(25)
                : Colors.grey.withAlpha(20),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? primaryBlue : Colors.grey.withAlpha(180),
        ),
      ),
    );
  }

  // Modern Premium Billing Card (Refined UI)
  Widget _buildBillingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(250),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200.withAlpha(140)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xff2563EB).withAlpha(16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xff2563EB).withAlpha(22)),
            ),
            child: const Text(
              "Billing Details",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff2563EB),
                letterSpacing: 0.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Rows (slightly spaced for clarity)
          _buildBillingRow("Subtotal", AppFormatter.formatPrice(subtotal)),

          const SizedBox(height: 8),

          _buildBillingRow(
            "GST ($gstPercent%)",
            AppFormatter.formatPrice(gstAmount),
          ),

          const SizedBox(height: 14),

          // Soft divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withAlpha(90),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Total section (more premium emphasis)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withAlpha(20)),
            ),
            child: _buildBillingRow(
              "Total Payable",
              AppFormatter.formatPrice(total),
              isBold: true,
              valueColor: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Clean, modern billing row
  Widget _buildBillingRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final productId = widget.product.pId;
    final qty = quantity;

    if (qty > widget.product.stockQty) {
      _showModernDialog(
        title: "Stock Error",
        message:
            "Cannot purchase $qty items. Only ${widget.product.stockQty} available.",
        buttonColor: Colors.redAccent,
        buttonText: "OK",
      );
      return;
    }

    // ✅ always update local stock first
    productController.reduceStockLocally(
      productId: productId.toString(),
      qty: qty,
    );

    final gstAmountPerItem = widget.product.price * gstPercent / 100;
    final totalGst = gstAmountPerItem * qty;
    final priceWithGSTPerItem = widget.product.price + gstAmountPerItem;

    final order = OrderModel(
      customerName: _nameController.text.trim(),
      totalAmount: priceWithGSTPerItem * qty,
      orderDate: DateTime.now(),
    );

    bool offline = false;

    // ✅ detect internet manually
    try {
      final result = await InternetAddress.lookup('google.com');
      offline = result.isEmpty;
    } catch (_) {
      offline = true;
    }

    //  save order anyway (Firestore queue or local db)
    orderController.addOrderWithItems(
      order: order,
      items: [
        {
          'product_id': productId,
          'product_name': widget.product.name,
          'image_path': widget.product.imagePath,
          'qty_sold': qty,
          'price_at_sale': priceWithGSTPerItem,
          'gst_amount': totalGst,
        },
      ],
    );

    if (!mounted) return;

    await _showModernDialog(
      title: offline ? "Saved Offline" : "Success",
      message: offline
          ? "Order stored locally. Will sync later."
          : "Order placed successfully.",
      buttonColor: offline ? Colors.orange : primaryBlue,
      buttonText: "OK",
      onPressed: () {
        Navigator.of(context).pop(); // close dialog
        Get.back(result: true); // go back
      },
    );
  }

  // Modern Dialog
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
                // Success Icon
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
                        color: Colors.green.shade200.withAlpha(20),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 40, color: Colors.white),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F172A),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
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

                // Confirm Button
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
                        letterSpacing: 0.5,
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
