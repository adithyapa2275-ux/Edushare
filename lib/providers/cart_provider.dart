import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class CartProvider extends ChangeNotifier {
  final Map<Book, int> _items = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CartProvider() {
    // Listen for auth state changes to load/clear cart
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadCartFromFirestore();
      } else {
        _items.clear();
        notifyListeners();
      }
    });
  }

  Map<Book, int> get items => _items;

  int get itemCount {
    int count = 0;
    _items.forEach((key, value) {
      count += value;
    });
    return count;
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((book, quantity) {
      total += book.price * quantity;
    });
    return total;
  }

  void addToCart(Book book) {
    if (_items.containsKey(book)) {
      _items[book] = _items[book]! + 1;
    } else {
      _items[book] = 1;
    }
    _saveCartToFirestore();
    notifyListeners();
  }

  void removeFromCart(Book book) {
    _items.remove(book);
    _saveCartToFirestore();
    notifyListeners();
  }

  void incrementQuantity(Book book) {
    if (_items.containsKey(book)) {
      _items[book] = _items[book]! + 1;
      _saveCartToFirestore();
      notifyListeners();
    }
  }

  void decrementQuantity(Book book) {
    if (_items.containsKey(book)) {
      if (_items[book]! > 1) {
        _items[book] = _items[book]! - 1;
      } else {
        _items.remove(book);
      }
      _saveCartToFirestore();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartToFirestore();
    notifyListeners();
  }

  // --- Firestore Persistence ---

  Future<void> _saveCartToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');

      // We can take a simple approach: delete old cart and rewrite.
      // For a production app, we'd sync individual items, but this is robust.
      final querySnapshot = await cartRef.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      for (var entry in _items.entries) {
        await cartRef.doc(entry.key.id).set({
          'book': entry.key.toMap(),
          'quantity': entry.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('CartProvider: Error saving cart: $e');
    }
  }

  Future<void> _loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');
      final querySnapshot = await cartRef.get();

      _items.clear();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final book = Book.fromMap(data['book'], doc.id);
        _items[book] = data['quantity'] ?? 1;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error loading cart: $e');
    }
  }
}
