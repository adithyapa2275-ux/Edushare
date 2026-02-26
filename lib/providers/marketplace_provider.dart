import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class MarketplaceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Book> _recentListings = [];
  List<Book> get recentListings => _recentListings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRecentListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('listings')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      _recentListings = snapshot.docs
          .map((doc) => Book.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching marketplace listings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
