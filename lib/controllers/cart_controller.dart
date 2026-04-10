import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../data/local/cart_db_helper.dart';
import '../data/model/product_model.dart';
import 'auth_controller.dart';

class CartItem {
  final ProductModel product;
  final RxInt qty;

  CartItem({
    required this.product,
    int initialQty = 1,
  }) : qty = initialQty.obs;
}

class CartController extends GetxController {
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCartFromDb();
  }

  // ================= LOAD FROM SQLITE =================
  Future<void> loadCartFromDb() async {
    final data = await CartDbHelper.getCartItems();
    cartItems.clear();

    for (var item in data) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthController.to.currentShopId)
          .collection('products')
          .doc(item['pId'].toString())
          .get();

      if (!doc.exists) continue;

      final firestoreData = doc.data()!;

      final product = ProductModel(
        pId: doc.id,
        name: firestoreData['name'] ?? '',
        price: (firestoreData['price'] ?? 0).toDouble(),
        imagePath: firestoreData['imagePath'] ?? '',
        stockQty: firestoreData['stockQty'] ?? 0,
        description: firestoreData['description'] ?? '',
      );

      cartItems.add(
        CartItem(
          product: product,
          initialQty: item['qty'] ?? 1,
        ),
      );
    }
  }

  // ================= ADD =================
  Future<void> addToCart(ProductModel product) async {
    final existing = cartItems.firstWhereOrNull(
          (c) => c.product.pId == product.pId,
    );

    if (existing != null) {
      existing.qty.value += 1;

      await CartDbHelper.insertOrUpdateCartItem({
        'pId': existing.product.pId,
        'name': existing.product.name,
        'price': existing.product.price,
        'imagePath': existing.product.imagePath,
        'stockQty': existing.product.stockQty,
        'qty': existing.qty.value,
      });
    } else {
      final item = CartItem(product: product);
      cartItems.add(item);

      await CartDbHelper.insertOrUpdateCartItem({
        'pId': product.pId,
        'name': product.name,
        'price': product.price,
        'imagePath': product.imagePath,
        'stockQty': product.stockQty,
        'qty': 1,
      });
    }
  }

  // ================= REMOVE =================
  Future<void> removeFromCart(CartItem item) async {
    cartItems.remove(item);
    await CartDbHelper.deleteCartItem(
      item.product.pId.toString(),
    );
  }

  // ================= INCREASE =================
  Future<void> increaseQty(CartItem item) async {
    item.qty.value += 1;

    await CartDbHelper.insertOrUpdateCartItem({
      'pId': item.product.pId,
      'name': item.product.name,
      'price': item.product.price,
      'imagePath': item.product.imagePath,
      'stockQty': item.product.stockQty,
      'qty': item.qty.value,
    });
  }

  // ================= DECREASE =================
  Future<void> decreaseQty(CartItem item) async {
    if (item.qty.value > 1) {
      item.qty.value -= 1;

      await CartDbHelper.insertOrUpdateCartItem({
        'pId': item.product.pId,
        'name': item.product.name,
        'price': item.product.price,
        'imagePath': item.product.imagePath,
        'stockQty': item.product.stockQty,
        'qty': item.qty.value,
      });
    } else {
      await removeFromCart(item);
    }
  }

  // ================= CLEAR =================
  Future<void> clearCart() async {
    cartItems.clear();
    await CartDbHelper.clearCart();
  }

  // ================= TOTAL =================
  double get totalPrice => cartItems.fold(
    0,
        (sum, item) => sum + (item.product.price * item.qty.value),
  );
  // cart in show
  bool isInCart(ProductModel product) {
    return cartItems.any((item) => item.product.pId == product.pId);
  }
  Future<void> toggleCart(ProductModel product) async {
    final existing = cartItems.firstWhereOrNull(
          (c) => c.product.pId == product.pId,
    );

    if (existing != null) {
      await removeFromCart(existing);
    } else {
      await addToCart(product);
    }
  }
}