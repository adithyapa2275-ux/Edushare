import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  void addOrder(OrderModel order) {
    _orders.insert(0, order); // Add newest first
    notifyListeners();
  }
}
