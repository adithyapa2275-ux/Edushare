import 'package:flutter/material.dart';
import '../models/book.dart';

class CartProvider extends ChangeNotifier {
  final Map<Book, int> _items = {};

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
    notifyListeners();
  }

  void removeFromCart(Book book) {
    _items.remove(book);
    notifyListeners();
  }

  void incrementQuantity(Book book) {
    if (_items.containsKey(book)) {
      _items[book] = _items[book]! + 1;
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
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
