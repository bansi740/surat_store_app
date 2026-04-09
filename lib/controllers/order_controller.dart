import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../data/model/order_model.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<OrderModel> orderList = <OrderModel>[].obs;

  StreamSubscription<List<OrderModel>>? _orderSubscription;

  String get shopId => AuthController.to.currentShopId ?? '';
  // old
  // ADD ORDER FOR CURRENT USER
  // Future<void> addOrderWithItems({
  //   required OrderModel order,
  //   required List<Map<String, dynamic>> items,
  // }) async {
  //   try {
  //     if (shopId.isEmpty) {
  //       throw Exception("Shop ID not found");
  //     }
  //
  //     // Create order inside user shop
  //     final orderRef = await _firestore
  //         .collection('users')
  //         .doc(shopId)
  //         .collection('orders')
  //         .add(order.toMap());
  //
  //     // Add items inside SAME order document
  //     for (final item in items) {
  //       await orderRef.collection('items').add(item);
  //     }
  //   } catch (e) {
  //     print("Error saving order with items: $e");
  //     rethrow;
  //   }
  // }
  // new
  Future<void> addOrderWithItems({
    required OrderModel order,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      if (shopId.isEmpty) {
        throw Exception("Shop ID not found");
      }

      final userRef = _firestore.collection('users').doc(shopId);

      // Create order
      final orderRef = await _firestore
          .collection('users')
          .doc(shopId)
          .collection('orders')
          .add(order.toMap());

      // Save order items + deduct stock
      for (final item in items) {
        await orderRef.collection('items').add(item);

        final productId = item['product_id'];
        final qtySold = item['qty_sold'] ?? 0;

        await userRef.collection('products').doc(productId).update({
          'stockQty': FieldValue.increment(-qtySold),
        });
      }
    } catch (e) {
      print("Error saving order with items: $e");
      rethrow;
    }
  }

  // STREAM CURRENT USER ORDERS
  Stream<List<OrderModel>> getUserOrders() {
    if (shopId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(shopId)
        .collection('orders')
        .orderBy('order_date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // TOTAL EARNINGS
  double get totalEarnings {
    return orderList.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // START USER ORDER LISTENER
  void startListeningOrders() {
    _orderSubscription?.cancel();

    if (shopId.isEmpty) {
      orderList.clear();
      return;
    }

    _orderSubscription = getUserOrders().listen((orders) {
      orderList.assignAll(orders);
    });
  }

  // CLEAR ORDERS
  void clearOrders() {
    orderList.clear();
    _orderSubscription?.cancel();
  }

  @override
  void onInit() {
    super.onInit();
    startListeningOrders();
  }

  @override
  void onClose() {
    _orderSubscription?.cancel();
    super.onClose();
  }
}
