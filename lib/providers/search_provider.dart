import 'package:flutter/material.dart';
import '../models/book.dart';
import '../core/api_service.dart';
import 'dart:async';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<Book> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  final ApiService _apiService = ApiService();

  String get query => _query;
  List<Book> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  void setQuery(String query) {
    _query = query;
    notifyListeners();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_query.isNotEmpty) {
        _performSearch(_query);
      } else {
        _searchResults = [];
        notifyListeners();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchBooks(query);
    } catch (e) {
      debugPrint("Search error: $e");
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _searchResults = [];
    notifyListeners();
  }
}
