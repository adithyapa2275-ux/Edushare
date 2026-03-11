import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class MarketplaceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Book> _recentListings = [];
  List<Book> get recentListings => _recentListings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _listingsSub;

  MarketplaceProvider() {
    _initListener();
  }

  void _initListener() {
    _isLoading = true;
    _listingsSub?.cancel();

    // Listen to ALL listings in real-time
    _listingsSub = _db
        .collection('listings')
        .snapshots()
        .listen(
          (snapshot) {
            debugPrint(
              'MarketplaceProvider: Received ${snapshot.docs.length} listings',
            );

            List<Book> listings = [];
            for (var doc in snapshot.docs) {
              try {
                listings.add(Book.fromMap(doc.data(), doc.id));
              } catch (e) {
                debugPrint('Error parsing listing ${doc.id}: $e');
              }
            }

            // Sort locally by timestamp (newest first)
            listings.sort((a, b) {
              if (a.uploadedAt == null && b.uploadedAt == null) return 0;
              if (a.uploadedAt == null) return 1;
              if (b.uploadedAt == null) return -1;
              return b.uploadedAt!.compareTo(a.uploadedAt!);
            });

            _recentListings = listings.take(20).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('MarketplaceProvider Error: $e');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // Keep for manual refresh if needed
  Future<void> fetchRecentListings() async => _initListener();

  @override
  void dispose() {
    _listingsSub?.cancel();
    super.dispose();
  }
}
