import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/database_helper.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final db = DatabaseHelper.instance;

  String shopId;

  SyncService(this.shopId);

  // ================= PUSH LOCAL → FIRESTORE =================
  Future<void> syncProductsToCloud() async {
    final products = await db.getUnsyncedProducts();

    for (final p in products) {
      final docRef = _firestore
          .collection('users')
          .doc(shopId)
          .collection('products')
          .doc(p['p_id'].toString());

      await docRef.set({
        'name': p['name'],
        'description': p['description'],
        'price': p['price'],
        'stockQty': p['stock_qty'],
        'imagePath': p['image_path'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await db.markOrderSynced(p['p_id']);
    }
  }

  // ================= PUSH ORDERS =================
  Future<void> syncOrdersToCloud() async {
    final orders = await db.getUnsyncedOrders();

    for (final o in orders) {
      final orderRef = _firestore
          .collection('users')
          .doc(shopId)
          .collection('orders')
          .doc(o['o_id'].toString());

      await orderRef.set({
        'customer_name': o['customer_name'],
        'total_amount': o['total_amount'],
        'order_date': o['order_date'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await db.markOrderSynced(o['o_id']);
    }
  }

  // ================= PULL CLOUD → LOCAL =================
  Future<void> pullProductsFromCloud() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(shopId)
        .collection('products')
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      await db.insertProduct({
        'p_id': int.tryParse(doc.id) ?? null,
        'name': data['name'],
        'description': data['description'],
        'price': data['price'],
        'stock_qty': data['stockQty'],
        'image_path': data['imagePath'],
        'is_synced': 1,
      });
    }
  }

  // ================= MASTER SYNC =================
  Future<void> syncAll() async {
    await syncProductsToCloud();
    await syncOrdersToCloud();
    await pullProductsFromCloud();
  }
}