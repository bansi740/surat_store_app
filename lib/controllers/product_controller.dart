import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../data/model/product_model.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs; // for search


  String get shopId => AuthController.to.currentShopId ?? '';

  CollectionReference get _productRef =>
      _firestore.collection('users').doc(shopId).collection('products');

  // ================= ADD PRODUCT =================
  Future<void> addProduct(ProductModel product) async {
    try {
      final doc = _productRef.doc();

      await doc.set({
        'pId': doc.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stockQty': product.stockQty,
        'imagePath': product.imagePath,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadProducts();
    } catch (e) {
      Get.snackbar("Error", "Failed to add product");
    }
  }

  // ================= LOAD PRODUCTS =================
  Future<void> loadProducts() async {
    try {
      final snapshot = await _productRef.get();

      productList.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return ProductModel(
          pId: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          stockQty: data['stockQty'] ?? 0,
          imagePath: data['imagePath'] ?? '',
        );
      }).toList();

      filteredProducts.assignAll(productList);
      initializePriceRange();
    } catch (e) {
      Get.snackbar("Error", "Failed to load products");
    }
  }

  // ================= UPDATE PRODUCT =================
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productRef.doc(product.pId.toString()).update({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stockQty': product.stockQty,
        'imagePath': product.imagePath,
      });

      await loadProducts();
    } catch (e) {
      Get.snackbar("Error", "Failed to update product");
    }
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(String productId) async {
    try {
      await _productRef.doc(productId).delete();
      await loadProducts();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete product");
    }
  }

  // ================= FILTER STATES =================
  String currentSearch = "";
  bool onlyInStock = false;
  double minPrice = 0;
  double maxPrice = 0;
  double defaultMinPrice = 0;
  double defaultMaxPrice = 0;
  String currentSort = "";

  // ================= SEARCH =================
  void searchProducts(String query) {
    currentSearch = query.trim().toLowerCase();
    applyFilters();
  }

  // ================= STOCK FILTER =================
  void filterInStock() {
    onlyInStock = true;
    applyFilters();
  }

  // ================= SORT LOW TO HIGH =================
  void sortPriceLowToHigh() {
    currentSort = "low";
    applyFilters();
  }

  // ================= SORT HIGH TO LOW =================
  void sortPriceHighToLow() {
    currentSort = "high";
    applyFilters();
  }

  // ================= PRICE RANGE =================
  void filterByPriceRange(double min, double max) {
    minPrice = min;
    maxPrice = max;
    applyFilters();
  }

  // ================= RESET =================
  void resetFilters() {
    currentSearch = "";
    onlyInStock = false;
    currentSort = "";
    minPrice = defaultMinPrice;
    maxPrice = defaultMaxPrice;
    filteredProducts.assignAll(productList);
  }

  // ================= MAIN FILTER ENGINE =================
  void applyFilters() {
    List<ProductModel> filtered = productList.where((p) {
      final matchesSearch = currentSearch.isEmpty ||
          p.name.toLowerCase().contains(currentSearch);

      final matchesStock = !onlyInStock || p.stockQty > 0;

      final matchesPrice =
          p.price >= minPrice && p.price <= maxPrice;

      return matchesSearch && matchesStock && matchesPrice;
    }).toList();

    if (currentSort == "low") {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (currentSort == "high") {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    filteredProducts.assignAll(filtered);
  }

  void initializePriceRange() {
    if (productList.isEmpty) {
      defaultMinPrice = 0;
      defaultMaxPrice = 10000;
      minPrice = defaultMinPrice;
      maxPrice = defaultMaxPrice;
      return;
    }

    final prices = productList.map((p) => p.price).toList();

    defaultMinPrice =
        prices.reduce((a, b) => a < b ? a : b);

    defaultMaxPrice =
        prices.reduce((a, b) => a > b ? a : b);

    minPrice = defaultMinPrice;
    maxPrice = defaultMaxPrice;
  }

}
