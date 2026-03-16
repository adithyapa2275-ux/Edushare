import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

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
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clearOrders();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final fetchedOrders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Local sort by descending date to avoid needing a Firestore composite index
      fetchedOrders.sort((a, b) => b.date.compareTo(a.date));

      _orders = fetchedOrders;
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    } finally {
      if (FirebaseFirestore.instance.app.name.isNotEmpty) {
         // ensure not cancelled before notify
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order); // Add newest first
    notifyListeners();
  }
}
