import 'package:get/get.dart';
import '../data/model/product_model.dart';

class CartItem {
  final ProductModel product;
  final RxInt qty; // reactive quantity

  CartItem({required this.product, int initialQty = 1}) : qty = initialQty.obs;
}

class CartController extends GetxController {
  // List of cart items
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  // Add product to cart
  void addToCart(ProductModel product) {
    // Check if product already in cart
    final existing = cartItems.firstWhereOrNull((c) => c.product.pId == product.pId);
    if (existing != null) {
      existing.qty.value += 1; // increment quantity
    } else {
      cartItems.add(CartItem(product: product));
    }
  }

  // Remove product from cart
  void removeFromCart(CartItem item) {
    cartItems.remove(item);
  }

  // Increase quantity
  void increaseQty(CartItem item) {
    item.qty.value += 1;
  }

  // Decrease quantity
  void decreaseQty(CartItem item) {
    if (item.qty.value > 1) {
      item.qty.value -= 1;
    } else {
      removeFromCart(item);
    }
  }

  // Clear cart
  void clearCart() {
    cartItems.clear();
  }

  // Total price
  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + (item.product.price * item.qty.value));
}