import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class CartProvider extends ChangeNotifier {
  final Map<Book, int> _items = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CartProvider() {
    _loadCartLocally().then((_) {
      // Listen for auth state changes to load/merge cart
      _auth.authStateChanges().listen((user) {
        if (user != null) {
          _loadCartFromFirestore();
        } else {
          // Keep local cart even after logout so the user doesn't lose items
          notifyListeners();
        }
      });
    });
  }

  /// Call this explicitly after login to make sure the cart is loaded.
  Future<void> loadCart() => _loadCartFromFirestore();

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
    _saveCartLocally();
    _saveCartToFirestore();
    notifyListeners();
  }

  void removeFromCart(Book book) {
    _items.remove(book);
    _saveCartLocally();
    _saveCartToFirestore();
    notifyListeners();
  }

  void incrementQuantity(Book book) {
    if (_items.containsKey(book)) {
      _items[book] = _items[book]! + 1;
      _saveCartLocally();
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
      _saveCartLocally();
      _saveCartToFirestore();
      notifyListeners();
    }
  }

  /// Clears the cart in memory AND in Firestore (e.g. after order is placed).
  void clearCart() {
    _items.clear();
    _saveCartLocally();
    _saveCartToFirestore();
    notifyListeners();
  }

  /// Clears cart only from memory (used on logout so Firestore data is preserved).
  void clearCartLocally() {
    _items.clear();
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

    _isLoading = true;
    notifyListeners();

    try {
      final cartRef = _db.collection('users').doc(user.uid).collection('cart');
      final querySnapshot = await cartRef.get();

      // We don't clear the local items immediately; we merge them.
      Map<Book, int> firestoreItems = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final bookMap = data['book'] as Map<String, dynamic>?;
        if (bookMap == null) continue;

        // Use the id stored inside the book map itself (more reliable than doc.id)
        final bookId = bookMap['id']?.toString() ?? doc.id;
        final book = Book.fromMap(bookMap, bookId);
        final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
        if (quantity > 0) {
          firestoreItems[book] = quantity;
        }
      }

      // Merge local items into firestore items
      _items.forEach((book, quantity) {
        firestoreItems[book] = quantity; // Local overrides firestore if running concurrently since login
      });
      
      _items.clear();
      _items.addAll(firestoreItems);

      _saveCartLocally(); // Save merged result locally
      _saveCartToFirestore(); // Save merged result back to firestore
      
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Local Persistence ---

  Future<void> _saveCartLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> cartData = {};
      
      _items.forEach((book, quantity) {
        cartData[book.id] = {
          'book': book.toMap(forLocal: true),
          'quantity': quantity,
        };
      });

      await prefs.setString('local_cart', jsonEncode(cartData));
    } catch (e) {
      debugPrint('CartProvider: Error saving cart locally: $e');
    }
  }

  Future<void> _loadCartLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('local_cart');
      
      if (cartString != null) {
        final Map<String, dynamic> cartData = jsonDecode(cartString);
        
        _items.clear();
        cartData.forEach((key, value) {
          final bookMap = value['book'] as Map<String, dynamic>?;
          if (bookMap != null) {
            final bookId = bookMap['id']?.toString() ?? key;
            final book = Book.fromMap(bookMap, bookId);
            final quantity = (value['quantity'] as num?)?.toInt() ?? 1;
            
            if (quantity > 0) {
              _items[book] = quantity;
            }
          }
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint('CartProvider: Error loading cart locally: $e');
    }
  }
}
