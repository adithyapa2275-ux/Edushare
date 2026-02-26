import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'Adithya'; // Default/Mock name
  String _email = 'adithya@example.com';
  String _phone = '+91 9876543210';
  String _address = '123, Gandhi Nagar, Bangalore, India';
  String _profileImage = ''; // Empty string means use default avatar

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get profileImage => _profileImage;

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
      try {
        final doc = await _db
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 5));
        if (doc.exists) {
          final data = doc.data()!;
          _name = data['name'] ?? _name;
          _email = data['email'] ?? _email;
          _phone = data['phone'] ?? _phone;
          _address = data['address'] ?? _address;
          _profileImage = data['profileImage'] ?? _profileImage;
          notifyListeners();
        }
      } catch (e) {
        print('UserProvider: Error loading user data: $e');
        // Fallback or just keep default mock values
      }
    }
  }

  void clearData() {
    _name = 'Adithya'; // Default/Mock name - maybe better empty?
    _email = 'adithya@example.com';
    _phone = '+91 9876543210';
    _address = '123, Gandhi Nagar, Bangalore, India';
    _profileImage = '';
    notifyListeners();
  }

  // Setters
  Future<void> updateUser({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
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

    await _db
        .collection('users')
        .doc(user.uid)
        .set(updates, SetOptions(merge: true));
    notifyListeners();
  }
}
