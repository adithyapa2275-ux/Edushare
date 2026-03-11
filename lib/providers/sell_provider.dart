import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class SellProvider extends ChangeNotifier {
  final List<Book> _userListings = [];
  bool _isLoading = false;

  List<Book> get userListings => _userListings;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SellProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadListings();
      } else {
        clearListings();
      }
    });
  }

  Future<void> loadListings() async {
    _isLoading = true; // Set loading to true
    notifyListeners(); // Notify listeners about loading state change

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _db
            .collection('listings')
            .where('sellerId', isEqualTo: user.uid)
            .get();
        _userListings.clear();
        for (var doc in snapshot.docs) {
          _userListings.add(Book.fromMap(doc.data(), doc.id));
        }
      }
    } catch (e) {
      // Handle error, e.g., print to console or show a snackbar
      debugPrint("Error loading listings: $e");
    } finally {
      _isLoading = false; // Set loading to false
      notifyListeners(); // Notify listeners about loading state change and data update
    }
  }

  void clearListings() {
    _userListings.clear();
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final bookData = {
      'title': book.title,
      'author': book.author,
      'imageUrl': book.imageUrl,
      'price': book.price,
      'description': book.description,
      'rating': book.rating,
      'reviewCount': book.reviewCount,
      'sellerId': user.uid,
      'uploaderId': user.uid,
      'sellerName': user.displayName ?? 'Anonymous User',
      'timestamp': FieldValue.serverTimestamp(),
      'categories': book.categories,
      'isBestSeller': book.isBestSeller,
      'isNewArrival': book.isNewArrival,
    };

    try {
      await _db.collection('listings').add(bookData);
      _userListings.add(book); // Local update for speed
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding book: $e");
      rethrow;
    }
  }

  Future<void> removeBook(String id) async {
    try {
      await _db.collection('listings').doc(id).delete();
      _userListings.removeWhere((book) => book.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing book: $e");
      rethrow;
    }
  }
}
