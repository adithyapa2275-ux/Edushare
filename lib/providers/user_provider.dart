import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadFromLocalCache(); // Load cached data instantly
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadUserData();
      } else {
        clearData();
      }
    });
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('user_name') ?? '';
      _profileImage = prefs.getString('user_profile_image') ?? '';
      _email = prefs.getString('user_email') ?? '';
      if (_name.isNotEmpty || _profileImage.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('UserProvider: Error loading from cache: $e');
    }
  }

  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _name);
      await prefs.setString('user_profile_image', _profileImage);
      await prefs.setString('user_email', _email);
    } catch (e) {
      debugPrint('UserProvider: Error saving to cache: $e');
    }
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
          _isAdmin =
              (data['isAdmin'] ?? false) || (_email == 'admin@edushare.com');
        } else {
          // If no doc exists, still use Auth email
          _email = user.email ?? '';
          _name = user.displayName ?? '';
          _isAdmin = (_email == 'admin@edushare.com');
        }
      } catch (e) {
        debugPrint('UserProvider: Error loading user data: $e');
        _email = user.email ?? '';
      } finally {
        _isLoading = false;
        _saveToLocalCache(); // Update cache with fresh Firestore data
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
    _clearLocalCache();
    notifyListeners();
  }

  Future<void> _clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('UserProvider: Error clearing cache: $e');
    }
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
    _saveToLocalCache(); // Update cache with fresh updates
    notifyListeners();
  }
}
