import 'book.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final Map<Book, int> items;
  final double totalAmount;
  final String deliveryAddress;

  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
  });
}
