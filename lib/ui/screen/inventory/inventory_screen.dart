import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../controllers/product_controller.dart';
import '../../../../core/utils/app_formatter.dart';
import '../../../../core/utils/assets.dart';
import '../../../../data/model/product_model.dart';
import 'inventory_animations.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final ProductController controller = Get.find<ProductController>();
  final _editFormKey = GlobalKey<FormState>();

  final Color primaryBlue = const Color(0xff2563EB);
  final Color bgColor = const Color(0xffF8FAFC);

  late AnimationController _animationController;
  late final ScrollController _scrollController;

  // Add a state variable to hold the new image temporarily

  @override
  void initState() {
    super.initState();

    controller.loadProducts();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0);
      }
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryBlue,
        elevation: 0,
        surfaceTintColor: primaryBlue,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
          child: const Text(
            'Inventory',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
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
      body: Obx(() {
        final products = controller.productList;

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: primaryBlue.withAlpha(12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 44,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'No Inventory Products',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add products to manage your stock',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final animations = InventoryAnimations(
          controller: _animationController,
          itemCount: products.length,
        );

        return ListView.builder(
          controller: _scrollController, // add this
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SlideTransition(
                position: animations.slideAnimations[index],
                child: FadeTransition(
                  opacity: animations.fadeAnimations[index],
                  child: ScaleTransition(
                    scale: animations.scaleAnimations[index],
                    child: _buildProductCard(product),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final int stock = product.stockQty;

    final bool isOut = stock == 0;
    final bool isLow = stock > 0 && stock <= 5;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isOut
            ? Colors.red.withAlpha(25)
            : isLow
            ? Colors.orange.withAlpha(25)
            : primaryBlue.withAlpha(25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOut
              ? Colors.red.withAlpha(35)
              : isLow
              ? Colors.orange.withAlpha(35)
              : primaryBlue.withAlpha(35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: "product_${product.pId}",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: product.imagePath.isNotEmpty
                  ? Image.file(
                File(product.imagePath),
                width: 66,
                height: 66,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: isOut
                      ? Colors.red.withAlpha(35)
                      : isLow
                      ? Colors.orange.withAlpha(35)
                      : primaryBlue.withAlpha(35),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isOut
                        ? Colors.red.withAlpha(25)
                        : isLow
                        ? Colors.orange.withAlpha(25)
                        : primaryBlue.withAlpha(25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 28,
                  color: isOut
                      ? Colors.red
                      : isLow
                      ? Colors.orange
                      : primaryBlue,
                ),
              ),
            ),
            ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      AppFormatter.formatPrice(product.price),
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOut
                            ? Colors.red.withAlpha(35)
                            : isLow
                            ? Colors.yellow.withAlpha(35)
                            : Colors.green.withAlpha(35),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        isOut
                            ? "Stock $stock"
                            : isLow
                            ? "Stock $stock"
                            : "Stock $stock",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOut
                              ? Colors.red
                              : isLow
                              ? Colors.orange.shade500
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton(
                icon: Icons.edit_rounded,
                color: primaryBlue,
                onTap: () => showEditDialog(context, product),
              ),
              const SizedBox(height: 10),
              _actionButton(
                icon: Icons.delete_rounded,
                color: Colors.red,
                onTap: () => showDeleteDialog(product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // action button for product card
  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(25),
          ),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // updated product
  void showEditDialog(BuildContext context, ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description);
    final priceController = TextEditingController(
      text: AppFormatter.inr.format(product.price),
    );
    final stockController = TextEditingController(
      text: product.stockQty.toString(),
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            16,
            18,
            MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  const Text(
                    'Update Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Show existing image only
                  if (product.imagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(product.imagePath),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, size: 40),
                    ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 16),
                  _buildEditField(
                    controller: nameController,
                    label: 'Product Name',
                    icon: Icons.shopping_bag_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is mandatory';
                      }
                      final isDuplicate = controller.productList.any(
                        (p) =>
                            p.name.toLowerCase() ==
                                value.trim().toLowerCase() &&
                            p.pId != product.pId,
                      );
                      if (isDuplicate) {
                        return 'Avoid duplicate product names';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildEditField(
                    controller: descController,
                    label: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditField(
                          controller: priceController,
                          label: 'Price',
                          icon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final price = AppFormatter.parsePrice(value ?? '');
                            if (price <= 0) {
                              return 'Price cannot be zero or negative';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildEditField(
                          controller: stockController,
                          label: 'Stock',
                          icon: Icons.inventory_2_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final stock = int.tryParse(value ?? '');
                            if (stock == null || stock < 0) {
                              return 'Stock cannot be negative';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (!_editFormKey.currentState!.validate()) return;

                        final updatedProduct = ProductModel(
                          pId: product.pId,
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          imagePath: product.imagePath,
                          isSynced: 0,
                          price: AppFormatter.parsePrice(
                            priceController.text.replaceAll(
                              RegExp(r'[^\d]'),
                              '',
                            ),
                          ),
                          stockQty: int.tryParse(stockController.text) ?? 0,
                        );

                        // 1. CLOSE BOTTOM SHEET FIRST (fix stuck UI)
                        Navigator.pop(context);

                        // 2. UPDATE LOCAL UI IMMEDIATELY
                        final index = controller.productList.indexWhere(
                          (p) => p.pId == product.pId,
                        );

                        if (index != -1) {
                          controller.productList[index] = updatedProduct;
                          controller.productList.refresh();
                        }

                        // 3. THEN UPDATE DB (offline safe)
                        await controller.updateProduct(updatedProduct);
                      },
                      child: const Text(
                        'Update Product',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // delete product
  void showDeleteDialog(ProductModel product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Delete Product',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to permanently delete this product?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // close sheet first
                        controller.deleteProduct(product.pId!); // then delete
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final bool isPriceField = label == "Price";

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: isPriceField
          ? [
              FilteringTextInputFormatter.digitsOnly,
              TextInputFormatter.withFunction((oldValue, newValue) {
                if (newValue.text.isEmpty) return newValue;

                final number = int.tryParse(newValue.text.replaceAll(',', ''));
                if (number == null) return oldValue;

                final formatted = AppFormatter.inr.format(number);
                return TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }),
            ]
          : keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: const Color(0xffF8FAFC),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xff2563EB), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }
}
