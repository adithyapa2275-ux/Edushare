import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart';

class OrderModel {
  final String id;
  final String userId;
  final DateTime date;
  final Map<Book, int> items;
  final double totalAmount;
  final String deliveryAddress;
  final String status;

  OrderModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    this.status = 'placed',
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'items': items.entries.map((e) => {
        'book': e.key.toMap(),
        'quantity': e.value,
      }).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();
    }

    Map<Book, int> parsedItems = {};
    if (map['items'] != null) {
      for (var item in map['items']) {
        if (item['book'] != null) {
          final book = Book.fromMap(item['book'], item['book']['id'] ?? '');
          parsedItems[book] = item['quantity'] as int;
        }
      }
    }

    return OrderModel(
      id: map['orderId'] ?? docId,
      userId: map['userId'] ?? '',
      date: parsedDate,
      items: parsedItems,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      deliveryAddress: map['deliveryAddress'] ?? '',
      status: map['status'] ?? 'placed',
    );
  }
}
