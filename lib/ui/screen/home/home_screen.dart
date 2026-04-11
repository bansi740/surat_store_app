import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/controllers/cart_controller.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/utils/app_formatter.dart';
import '../buy/buy_screen.dart';
import 'custom_price_dialog.dart';
import 'home_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();

  final Color primaryBlue = const Color(0xff2563EB);
  final Color darkBlue = const Color(0xff1E40AF);

  late final ScrollController _scrollController;

  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();

    productController.loadProducts();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0);
      }
    });
    _scrollController = ScrollController();
    // search
    _searchFocus.addListener(() {
      isSearchFocused.value = _searchFocus.hasFocus;
    });
  }

  // search
  final TextEditingController _searchController = TextEditingController();
  var searchQuery = "".obs; // Observable for filtering
  final RxBool isSearchFocused = false.obs;
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      // Gradient AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff2563EB), Color(0xff1E40AF)],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
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
                "Surat Store",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),

      body: GestureDetector(
        onTap: () {
          _searchFocus.unfocus();
        },
        child: Column(
          children: [
            // search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Obx(
                      () => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isSearchFocused.value
                                ? const Color(0xFF1565C0) // focused border
                                : Colors.grey.shade300, // default border
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          onChanged: (value) {
                            searchQuery.value = value;
                            productController.searchProducts(value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search products...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Icon(
                                Icons.search_rounded,
                                color: Colors.grey.shade600,
                                size: 22,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 42,
                              minHeight: 42,
                            ),
                            suffixIcon: searchQuery.value.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      productController.searchProducts("");
                                      searchQuery.value = "";
                                      _searchFocus.requestFocus();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Button
                  PopupMenuButton<String>(
                    onOpened: () {
                      setState(() {
                        isMenuOpen = true;
                      });
                    },
                    onCanceled: () {
                      setState(() {
                        isMenuOpen = false;
                      });
                    },
                    offset: const Offset(2, 73),
                    color: Colors.white,
                    splashRadius: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 165,
                      maxWidth: 260,
                      maxHeight: 290, //  popup height added
                    ),
                    onSelected: (value) async {
                      setState(() {
                        isMenuOpen = false;
                      });
                      if (value == "stock") {
                        productController.filterInStock();
                      } else if (value == "price_low") {
                        productController.sortPriceLowToHigh();
                      } else if (value == "price_high") {
                        productController.sortPriceHighToLow();
                      } else if (value == "custom_price") {
                        showDialog(
                          context: context,
                          builder: (context) => CustomPriceDialog(
                            onApply: (min, max) {
                              productController.filterByPriceRange(min, max);
                            },
                          ),
                        );
                      } else if (value == "reset") {
                        productController.resetFilters();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "stock",
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 20),
                            SizedBox(width: 10),
                            Text("In Stock"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "price_low",
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward_rounded, size: 20),
                            SizedBox(width: 10),
                            Text("Price Low to High"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "price_high",
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward_rounded, size: 20),
                            SizedBox(width: 10),
                            Text("Price High to Low"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "custom_price",
                        child: Row(
                          children: [
                            Icon(Icons.currency_rupee_rounded, size: 20),
                            SizedBox(width: 10),
                            Text("Custom Price"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "reset",
                        child: Row(
                          children: [
                            Icon(Icons.category_outlined, size: 20),
                            SizedBox(width: 10),
                            Text("Reset Filters"),
                          ],
                        ),
                      ),
                    ],
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: isMenuOpen
                            ? const Color(0xFF1565C0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 24,
                        color: isMenuOpen
                            ? Colors.white
                            : const Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final products = productController.filteredProducts;

                // When building your list view
                if (products.isEmpty) {
                  return buildEmptyState(
                    isSearchEmpty: searchQuery.value.isNotEmpty,
                    query: searchQuery.value,
                  );
                }

                final animations = HomeAnimations(
                  controller: _animationController,
                  itemCount: products.length,
                );

                return GridView.builder(
                  controller: _scrollController,
                  // add this
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  // smooth bounce scroll
                  cacheExtent: 800,
                  // preload items
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return RepaintBoundary(
                      child: SlideTransition(
                        position: animations.slideAnimations[index],
                        child: FadeTransition(
                          opacity: animations.fadeAnimations[index],
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image section with border for empty images
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(22),
                                      topRight: Radius.circular(22),
                                    ),
                                    child:
                                        product.imagePath.isNotEmpty &&
                                            File(product.imagePath).existsSync()
                                        ? Image.file(
                                            File(product.imagePath),
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xffF3F4F6),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                // subtle border
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      22,
                                                    ),
                                                    topRight: Radius.circular(
                                                      22,
                                                    ),
                                                  ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: primaryBlue,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Info section
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product name
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Stock with color indicator
                                      Row(
                                        children: [
                                          Text(
                                            product.stockQty == 0
                                                ? "Out of Stock"
                                                : "Stock: ${product.stockQty}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: product.stockQty == 0
                                                  ? Colors.red
                                                  : (product.stockQty > 5
                                                        ? Colors.grey.shade500
                                                        : Colors.orange),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Price
                                      Text(
                                        AppFormatter.formatPrice(product.price),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Buttons row
                                      Row(
                                        children: [
                                          Obx(() {
                                            final isAdded = cartController
                                                .isInCart(product);

                                            return SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await cartController
                                                      .toggleCart(product);

                                                  Get.snackbar(
                                                    isAdded
                                                        ? "Removed from Cart"
                                                        : "Added to Cart",
                                                    isAdded
                                                        ? "${product.name} removed from cart"
                                                        : "${product.name} added to cart",
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.white,
                                                    colorText: Colors.black87,
                                                    duration: const Duration(
                                                      seconds: 1,
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isAdded
                                                      ? const Color(0xffDCFCE7)
                                                      : const Color(0xffEFF6FF),
                                                  padding: EdgeInsets.zero,
                                                  elevation: 0,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                    side: BorderSide(
                                                      color:
                                                          isAdded
                                                                ? const Color(
                                                                    0xff16A34A,
                                                                  ).withAlpha(
                                                                    25,
                                                                  )
                                                                : const Color(
                                                                    0xff2563EB,
                                                                  )
                                                            ..withAlpha(25),
                                                      width: 0.7,
                                                    ),
                                                  ),
                                                ),
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  transitionBuilder:
                                                      (child, animation) =>
                                                          ScaleTransition(
                                                            scale: animation,
                                                            child: child,
                                                          ),
                                                  child: Icon(
                                                    isAdded
                                                        ? Icons.check_rounded
                                                        : Icons.add_shopping_cart,
                                                    key: ValueKey(isAdded),
                                                    color: isAdded
                                                        ? const Color(
                                                            0xff16A34A,
                                                          )
                                                        : const Color(
                                                            0xff2563EB,
                                                          ),
                                                    size: 19,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Clear search before navigating
                                                  _searchController.clear();
                                                  searchQuery.value = "";
                                                  productController
                                                      .searchProducts(
                                                        "",
                                                      ); // reset filter
                                                  _searchFocus.unfocus();

                                                  Get.to(
                                                    () => BuyScreen(
                                                      product: product,
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xff2563EB,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          28,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Buy",
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
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState({bool isSearchEmpty = false, String? query}) {
    String title;
    String subtitle;

    if (isSearchEmpty && (query?.isNotEmpty ?? false)) {
      title = "No Products Found";
      subtitle =
          "We couldn't find any products matching \"$query\".\nTry adjusting your search or filters.";
    } else {
      title = "No Products Yet";
      subtitle = "Welcome to Surat Store\nStart by adding your first product";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: primaryBlue.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 42,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: Color(0xff0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
