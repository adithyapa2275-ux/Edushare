import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  OrderProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        clearOrders();
      }
    });
  }

  void clearOrders() {
    _orders.clear();
    _ordersSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  void fetchOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clearOrders();
      return;
    }

    if (_orders.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    _ordersSubscription?.cancel();
    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      final fetchedOrders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Local sort by descending date
      fetchedOrders.sort((a, b) => b.date.compareTo(a.date));

      _orders = fetchedOrders;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error fetching orders: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order); // Add newest first
    notifyListeners();
  }
}
