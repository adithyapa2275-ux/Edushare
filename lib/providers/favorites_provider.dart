import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';
class FavoritesProvider extends ChangeNotifier {
  final Set<Book> _favorites = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FavoritesProvider() {
    _loadFavoritesLocally().then((_) {
      _auth.authStateChanges().listen((user) {
        if (user != null) {
          _loadFavoritesFromFirestore();
        } else {
          // Keep local favorites when logged out
          notifyListeners();
        }
      });
    });
  }

  List<Book> get favorites => _favorites.toList();

  bool isFavorite(Book book) => _favorites.contains(book);

  void toggleFavorite(Book book) {
    if (_favorites.contains(book)) {
      _favorites.remove(book);
    } else {
      _favorites.add(book);
    }
    _saveFavoritesLocally();
    _saveFavoritesToFirestore();
    notifyListeners();
  }

  // --- Firestore Persistence ---

  Future<void> _saveFavoritesToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _db.collection('users').doc(user.uid);
      
      final List<Map<String, dynamic>> favList = _favorites.map((b) => b.toMap()).toList();
      
      await docRef.set({
        'favorites': favList,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FavoritesProvider: Error saving to Firestore: $e');
    }
  }

  Future<void> _loadFavoritesFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docSnapshot = await _db.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('favorites')) {
          final List<dynamic> favList = data['favorites'];
          
          Set<Book> firestoreFavorites = {};
          
          for (var item in favList) {
            final bookMap = item as Map<String, dynamic>;
            final bookId = bookMap['id']?.toString() ?? '';
            if (bookId.isNotEmpty) {
              firestoreFavorites.add(Book.fromMap(bookMap, bookId));
            }
          }

          // Merge local into firestore
          firestoreFavorites.addAll(_favorites);
          
          _favorites.clear();
          _favorites.addAll(firestoreFavorites);

          _saveFavoritesLocally();
          _saveFavoritesToFirestore(); // sync back if we merged new ones
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('FavoritesProvider: Error loading from Firestore: $e');
    }
  }

  // --- Local Persistence ---

  Future<void> _saveFavoritesLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> favList = _favorites.map((b) => b.toMap(forLocal: true)).toList();
      await prefs.setString('local_favorites', jsonEncode(favList));
    } catch (e) {
      debugPrint('FavoritesProvider: Error saving locally: $e');
    }
  }

  Future<void> _loadFavoritesLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favString = prefs.getString('local_favorites');
      
      if (favString != null) {
        final List<dynamic> favList = jsonDecode(favString);
        _favorites.clear();
        for (var item in favList) {
          final bookMap = item as Map<String, dynamic>;
          final bookId = bookMap['id']?.toString() ?? '';
          if (bookId.isNotEmpty) {
            _favorites.add(Book.fromMap(bookMap, bookId));
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('FavoritesProvider: Error loading locally: $e');
    }
  }
}
