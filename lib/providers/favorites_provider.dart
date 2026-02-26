import 'package:flutter/material.dart';
import '../models/book.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<Book> _favorites = {};

  List<Book> get favorites => _favorites.toList();

  bool isFavorite(Book book) => _favorites.contains(book);

  void toggleFavorite(Book book) {
    if (_favorites.contains(book)) {
      _favorites.remove(book);
    } else {
      _favorites.add(book);
    }
    notifyListeners();
  }
}
