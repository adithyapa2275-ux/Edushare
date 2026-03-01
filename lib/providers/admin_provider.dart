import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get allUsers => _allUsers;

  List<Book> _allListings = [];
  List<Book> get allListings => _allListings;

  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  bool _isLoadingListings = false;
  bool get isLoadingListings => _isLoadingListings;

  Future<void> fetchAllUsers() async {
    _isLoadingUsers = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('users').get();
      _allUsers = snapshot.docs.map((doc) {
        var data = doc.data();
        data['uid'] = doc.id; // Inject ID for updates
        return data;
      }).toList();
    } catch (e) {
      print('AdminProvider: Error fetching users: $e');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllListings() async {
    _isLoadingListings = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('listings')
          .orderBy('timestamp', descending: true)
          .get();

      _allListings = snapshot.docs
          .map((doc) => Book.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('AdminProvider: Error fetching listings: $e');
    } finally {
      _isLoadingListings = false;
      notifyListeners();
    }
  }

  Future<bool> toggleUserAdminStatus(String uid, bool currentStatus) async {
    try {
      await _db.collection('users').doc(uid).update({
        'isAdmin': !currentStatus,
      });
      // Update local state to avoid refetching everything immediately
      final index = _allUsers.indexWhere((u) => u['uid'] == uid);
      if (index != -1) {
        _allUsers[index]['isAdmin'] = !currentStatus;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('AdminProvider: Error toggling admin status: $e');
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      await _db.collection('listings').doc(listingId).delete();
      _allListings.removeWhere((book) => book.id == listingId);
      notifyListeners();
      return true;
    } catch (e) {
      print('AdminProvider: Error deleting listing: $e');
      return false;
    }
  }
}
