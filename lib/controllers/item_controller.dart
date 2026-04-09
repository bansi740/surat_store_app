import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ItemController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  Future<void> saveOrderToFirestore({
    required String customerName,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      isLoading.value = true;

      // Create order document
      final orderRef = _firestore.collection('orders').doc();

      await orderRef.set({
        'customer_name': customerName,
        'total_amount': totalAmount,
        'order_date': DateTime.now().toIso8601String(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // Add items subcollection
      for (final item in items) {
        await orderRef.collection('items').add({
          'product_id': item['product_id'],
          'qty_sold': item['qty_sold'],
          'price_at_sale': item['price_at_sale'],
        });
      }

      Get.snackbar("Success", "Order saved to Firestore");
    } catch (e) {
      Get.snackbar("Error", "Failed to save order: $e");
    } finally {
      isLoading.value = false;
    }
  }
}