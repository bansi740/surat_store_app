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
  final double gstPercent = 5.0;
  final Color primaryBlue = const Color(0xff2563EB);
  final Color primaryGreen = const Color(0xff16A34A);

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28 ),
                    child:
                        widget.product.imagePath.isNotEmpty &&
                            File(widget.product.imagePath).existsSync()
                        ? Image.file(
                            File(widget.product.imagePath),
                            height: 220,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
                const SizedBox(height: 16),

                // Product Info
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.product.description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Stock: ${widget.product.stockQty}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: widget.product.stockQty > 5
                        ? Colors.grey.shade500
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Price: ${AppFormatter.formatPrice(widget.product.price)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),

                // Quantity Selector
                _buildQuantitySelector(),

                const SizedBox(height: 20),

                // Billing Card
                _buildBillingCard(),

                const SizedBox(height: 20),

                Text("Customer Details",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.black),),
                const SizedBox(height: 10,),
                // Name Input with validation
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter Customer Name",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryBlue.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, color: primaryBlue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: primaryBlue, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name cannot be empty";
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
                          onPressed: widget.product.stockQty == 0 ? null : _confirmPurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.product.stockQty == 0 ? Colors.grey.shade400 : primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            widget.product.stockQty == 0 ? "Out of Stock" : "Confirm Purchase",
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
    // Disable both buttons if stock is 0
    final bool outOfStock = widget.product.stockQty == 0;
    final bool canDecrease = !outOfStock && quantity > 1;
    final bool canIncrease = !outOfStock && quantity < widget.product.stockQty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Quantity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              _quantityButton(
                icon: Icons.remove,
                enabled: canDecrease,
                onTap: () => setState(() => quantity--),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  outOfStock ? "0" : quantity.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),

              _quantityButton(
                icon: Icons.add,
                enabled: canIncrease,
                onTap: () => setState(() => quantity++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // quantity button
  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? primaryBlue.withAlpha(25) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: enabled ? primaryBlue : Colors.grey),
      ),
    );
  }

  // Modern & Clean Billing Card
  Widget _buildBillingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with subtle accent
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Billing Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Subtotal
          _buildBillingRow("Subtotal", AppFormatter.formatPrice(subtotal)),

          // GST
          _buildBillingRow(
            "GST ($gstPercent%)",
            AppFormatter.formatPrice(gstAmount),
          ),

          const Divider(height: 20, thickness: 1, color: Colors.grey),

          // Total row highlighted
          _buildBillingRow(
            "Total",
            AppFormatter.formatPrice(total),
            isBold: true,
            valueColor: Colors.green.shade700,
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

    if (quantity > widget.product.stockQty) {
      _showModernDialog(
        title: "Stock Error",
        message: "Cannot purchase $quantity items. Only ${widget.product.stockQty} available.",
        buttonColor: Colors.redAccent,
        buttonText: "OK",
      );
      return;
    }

    // GST and price calculations
    double gstAmountPerItem = widget.product.price * gstPercent / 100;  // GST for 1 item
    double totalGst = gstAmountPerItem * quantity;                       // GST for all items
    double priceWithGSTPerItem = widget.product.price + gstAmountPerItem;
    double totalPriceWithGST = priceWithGSTPerItem * quantity;          // Total including GST

    final order = OrderModel(
      customerName: _nameController.text.trim(),
      totalAmount: totalPriceWithGST, // total including GST
      orderDate: DateTime.now(),
    );

    try {
      await orderController.addOrderWithItems(
        order: order,
        items: [
          {
            'product_id': widget.product.pId,
            'product_name': widget.product.name,
            'image_path': widget.product.imagePath,
            'qty_sold': quantity,
            'price_at_sale': priceWithGSTPerItem,  // price per item including GST
            'gst_amount': totalGst,                // GST for all items
          },
        ],
      );
      await productController.loadProducts();
      _showModernDialog(
        title: "Thank You!",
        message: "Your order for ${widget.product.name} ($quantity pcs) has been placed successfully.",
        buttonColor: primaryBlue,
        buttonText: "OK",
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      _showModernDialog(
        title: "Error",
        message: "Failed to place order.\n$e",
        buttonColor: Colors.redAccent,
        buttonText: "OK",
      );
    }
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
                  child: const Icon(
                    Icons.check,
                    size: 40,
                    color: Colors.white,
                  ),
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
