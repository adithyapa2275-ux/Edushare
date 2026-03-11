import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get allUsers => _allUsers;

  List<Book> _allListings = [];
  List<Book> get allListings => _allListings;

  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> get allOrders => _allOrders;

  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  bool _isLoadingListings = false;
  bool get isLoadingListings => _isLoadingListings;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  StreamSubscription? _usersSub;
  StreamSubscription? _listingsSub;
  StreamSubscription? _ordersSub;

  AdminProvider() {
    _initListeners();
  }

  void _initListeners() {
    _startUsersListener();
    _startListingsListener();
    _startOrdersListener();
  }

  void _startUsersListener() {
    _isLoadingUsers = true;
    _usersSub?.cancel();
    _usersSub = _db
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            debugPrint(
              '🔥 [ADMIN] Users Snapshot received: ${snapshot.docs.length} documents',
            );
            List<Map<String, dynamic>> users = [];
            for (var doc in snapshot.docs) {
              try {
                var data = doc.data();
                data['uid'] = doc.id;
                users.add(data);
              } catch (e) {
                debugPrint('⚠️ Error parsing user ${doc.id}: $e');
              }
            }
            _allUsers = users;
            _isLoadingUsers = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('AdminProvider: Users Stream Error: $e');
            _isLoadingUsers = false;
            notifyListeners();
          },
        );
  }

  void _startListingsListener() {
    _isLoadingListings = true;
    _listingsSub?.cancel();
    _listingsSub = _db
        .collection('listings')
        .snapshots()
        .listen(
          (snapshot) {
            debugPrint(
              '🔥 [ADMIN] Listings Snapshot received: ${snapshot.docs.length} documents',
            );
            List<Book> listings = [];
            for (var doc in snapshot.docs) {
              try {
                listings.add(Book.fromMap(doc.data(), doc.id));
              } catch (e) {
                debugPrint('⚠️ Error parsing listing ${doc.id}: $e');
              }
            }
            _allListings = listings;

            // Local sort by timestamp if available
            _allListings.sort((a, b) {
              if (a.uploadedAt == null && b.uploadedAt == null) return 0;
              if (a.uploadedAt == null) return 1;
              if (b.uploadedAt == null) return -1;
              return b.uploadedAt!.compareTo(a.uploadedAt!);
            });

            _isLoadingListings = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('AdminProvider: Listings Stream Error: $e');
            _isLoadingListings = false;
            notifyListeners();
          },
        );
  }

  void _startOrdersListener() {
    _isLoadingOrders = true;
    _ordersSub?.cancel();
    _ordersSub = _db
        .collection('orders')
        .snapshots()
        .listen(
          (snapshot) {
            debugPrint(
              '🔥 [ADMIN] Orders Snapshot received: ${snapshot.docs.length} documents',
            );
            List<Map<String, dynamic>> orders = [];
            for (var doc in snapshot.docs) {
              try {
                var data = doc.data();
                data['orderId'] = doc.id;
                orders.add(data);
              } catch (e) {
                debugPrint('Error parsing order ${doc.id}: $e');
              }
            }
            _allOrders = orders;
            _isLoadingOrders = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('AdminProvider: Orders Stream Error: $e');
            _isLoadingOrders = false;
            notifyListeners();
          },
        );
  }

  // Keep these as manual refresh triggers if needed, but they just restart listeners
  Future<void> fetchAllUsers() async => _startUsersListener();
  Future<void> fetchAllListings() async => _startListingsListener();
  Future<void> fetchAllOrders() async => _startOrdersListener();

  Future<bool> toggleUserAdminStatus(String uid, bool currentStatus) async {
    try {
      await _db.collection('users').doc(uid).update({
        'isAdmin': !currentStatus,
      });
      return true;
    } catch (e) {
      debugPrint('AdminProvider: Error toggling admin status: $e');
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      await _db.collection('listings').doc(listingId).delete();
      return true;
    } catch (e) {
      debugPrint('AdminProvider: Error deleting listing: $e');
      return false;
    }
  }

  int get totalSellers {
    final sellers = _allListings.map((b) => b.uploaderId).toSet();
    return sellers.length;
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _listingsSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}
