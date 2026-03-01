import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _profileImage = '';
  bool _isAdmin = false;
  bool _isLoading = true;

  // Getters
  String get name => _name.isEmpty ? 'User' : _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get profileImage => _profileImage;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadUserData();
      } else {
        clearData();
      }
    });
  }

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final doc = await _db
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 5));
        if (doc.exists) {
          final data = doc.data()!;
          _name = data['name'] ?? '';
          _email = data['email'] ?? user.email ?? '';
          _phone = data['phone'] ?? '';
          _address = data['address'] ?? '';
          _profileImage = data['profileImage'] ?? '';
          _isAdmin = data['isAdmin'] ?? false;
        } else {
          // If no doc exists, still use Auth email
          _email = user.email ?? '';
          _name = user.displayName ?? '';
        }
      } catch (e) {
        print('UserProvider: Error loading user data: $e');
        _email = user.email ?? '';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _name = '';
    _email = '';
    _phone = '';
    _address = '';
    _profileImage = '';
    _isAdmin = false;
    _isLoading = false;
    notifyListeners();
  }

  // Setters
  Future<void> updateUser({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    bool? isAdmin,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) {
      _name = name;
      updates['name'] = name;
    }
    if (email != null) {
      _email = email;
      updates['email'] = email;
    }
    if (phone != null) {
      _phone = phone;
      updates['phone'] = phone;
    }
    if (address != null) {
      _address = address;
      updates['address'] = address;
    }
    if (profileImage != null) {
      _profileImage = profileImage;
      updates['profileImage'] = profileImage;
    }
    if (isAdmin != null) {
      _isAdmin = isAdmin;
      updates['isAdmin'] = isAdmin;
    }

    await _db
        .collection('users')
        .doc(user.uid)
        .set(updates, SetOptions(merge: true));
    notifyListeners();
  }
}
