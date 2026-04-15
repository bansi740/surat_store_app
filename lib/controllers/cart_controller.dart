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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadCartFromDb();
  }

  // ================= FIRESTORE SAVE =================
  Future<void> _saveToFirestore(String userId, CartItem item) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(item.product.pId.toString())
        .set({
      'pId': item.product.pId,
      'name': item.product.name,
      'price': item.product.price,
      'imagePath': item.product.imagePath,
      'stockQty': item.product.stockQty,
      'qty': item.qty.value,
    }, SetOptions(merge: true));
  }

  // ================= FIRESTORE DELETE =================
  Future<void> _deleteFromFirestore(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // ================= LOAD FROM FIRESTORE + SQLITE =================
  Future<void> loadCartFromDb() async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    cartItems.clear();

    // 1. Try Firestore first (for reinstall support)
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        final data = doc.data();

        final product = ProductModel(
          pId: data['pId'],
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          imagePath: data['imagePath'] ?? '',
          stockQty: data['stockQty'] ?? 0,
          description: '',
        );

        cartItems.add(
          CartItem(
            product: product,
            initialQty: data['qty'] ?? 1,
          ),
        );
      }
      return;
    }

    // 2. fallback: SQLite (your old data)
    final data = await CartDbHelper.getCartItems(userId);

    for (var item in data) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
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

      await _saveToFirestore(userId, cartItems.last);
    }
  }

  // ================= ADD =================
  Future<void> addToCart(ProductModel product) async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

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
      }, userId);

      await _saveToFirestore(userId, existing);
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
      }, userId);

      await _saveToFirestore(userId, item);
    }
  }

  // ================= REMOVE =================
  Future<void> removeFromCart(CartItem item) async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    cartItems.remove(item);

    await CartDbHelper.deleteCartItem(
      userId,
      item.product.pId.toString(),
    );

    await _deleteFromFirestore(userId, item.product.pId.toString());
  }

  // ================= INCREASE =================
  Future<void> increaseQty(CartItem item) async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    item.qty.value += 1;

    await CartDbHelper.insertOrUpdateCartItem({
      'pId': item.product.pId,
      'name': item.product.name,
      'price': item.product.price,
      'imagePath': item.product.imagePath,
      'stockQty': item.product.stockQty,
      'qty': item.qty.value,
    }, userId);

    await _saveToFirestore(userId, item);
  }

  // ================= DECREASE =================
  Future<void> decreaseQty(CartItem item) async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    if (item.qty.value > 1) {
      item.qty.value -= 1;

      await CartDbHelper.insertOrUpdateCartItem({
        'pId': item.product.pId,
        'name': item.product.name,
        'price': item.product.price,
        'imagePath': item.product.imagePath,
        'stockQty': item.product.stockQty,
        'qty': item.qty.value,
      }, userId);

      await _saveToFirestore(userId, item);
    } else {
      await removeFromCart(item);
    }
  }

  // ================= CLEAR =================
  Future<void> clearCart() async {
    final userId = AuthController.to.currentShopId;
    if (userId == null) return;

    cartItems.clear();
    await CartDbHelper.clearCart(userId);

    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart');

    final docs = await ref.get();

    for (var d in docs.docs) {
      await d.reference.delete();
    }
  }

  // ================= TOTAL =================
  double get totalPrice => cartItems.fold(
    0,
        (sum, item) => sum + (item.product.price * item.qty.value),
  );

  // ================= CHECK =================
  bool isInCart(ProductModel product) {
    return cartItems.any((item) => item.product.pId == product.pId);
  }

  // ================= TOGGLE =================
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