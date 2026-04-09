import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? id;
  String customerName;
  double totalAmount;
  DateTime orderDate;
  bool isSynced;

  OrderModel({
    this.id,
    required this.customerName,
    required this.totalAmount,
    required this.orderDate,
    this.isSynced = false,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'total_amount': totalAmount,
      'order_date': Timestamp.fromDate(orderDate), // Firestore Timestamp
      'is_synced': isSynced,
    };
  }

  // Convert Firestore doc to OrderModel
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      customerName: map['customer_name'] ?? '',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      orderDate: (map['order_date'] as Timestamp).toDate(),
      isSynced: map['is_synced'] ?? false,
    );
  }
}