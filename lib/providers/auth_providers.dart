import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  UserModel? _user;

  // ---------------- GETTERS ----------------
  bool get isLoading => _isLoading;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  // ---------------- LOGIN ----------------
  Future<bool> login(String email, String password) async {
    final response = await ApiService.login(email, password);

    if (response["success"] == true && response["user"] != null) {
      _user = UserModel.fromJson(response["user"]);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ---------------- LOAD USER FROM STORAGE ----------------
  Future<void> loadUser() async {
    // Reserved for future persistence
  }

  // ---------------- LOAD SESSION ----------------
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('logged_in') ?? false;

    if (!loggedIn) {
      _user = null;
    }

    notifyListeners();
  }

  // ---------------- SIGNUP ----------------
  Future<bool> signup({
    required String fullName,
    required String dob,
    required String location,
    required String nationality,
    required String email,
    required String phone,
    required String occupation,
    required String qualification,
    required String maritalStatus,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.signup({
        "full_name": fullName,
        "dob": dob,
        "location": location,
        "nationality": nationality,
        "email": email,
        "phone": phone,
        "occupation": occupation,
        "qualification": qualification,
        "marital_status": maritalStatus,
        "password": password,
        "confirm_password": confirmPassword,
      });

      _isLoading = false;
      notifyListeners();

      return response['success'] == true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // ---------------- UPDATE ALL USER FIELDS ----------------
  void updateUser({
    required String fullName,
    required String dob,
    required String location,
    required String occupation,
    required String qualification,
    required String nationality,
    required String phone,
    required String maritalStatus,
  }) {
    if (_user == null) return;

    _user = _user!.copyWith(
      fullName: fullName,
      dob: dob,
      location: location,
      occupation: occupation,
      qualification: qualification,
      nationality: nationality,
      phone: phone,
      maritalStatus: maritalStatus,
    );

    notifyListeners();
  }

  // ---------------- UPDATE PROFILE IMAGE ----------------
  void updateProfileImage(String imagePath) {
    if (_user == null) return;

    _user = _user!.copyWith(profileImage: imagePath);
    notifyListeners();
  }
}
