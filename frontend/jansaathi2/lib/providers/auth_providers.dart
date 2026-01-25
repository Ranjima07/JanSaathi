import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isLoading = false;
  UserModel? _user;

  String? _verificationId;

  // ---------------- GETTERS ----------------
  bool get isLoading => _isLoading;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  // ---------------- PASSWORD LOGIN ----------------
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);

      if (response["success"] == true && response["user"] != null) {
        _user = UserModel.fromJson(response["user"]);
        await _persistLogin();
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---------------- SEND OTP (FIREBASE) ----------------
  Future<void> sendOtp(String mobile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91$mobile", // India country code
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (rare but possible)
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(e.message ?? "OTP verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- VERIFY OTP (FIREBASE) ----------------
  Future<bool> verifyOtp(String mobile, String otp) async {
    if (_verificationId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Create user model (backend sync can be added here)
        _user = UserModel.fromJson({
          "full_name": "Citizen",
          "dob": "",
          "location": "",
          "nationality": "",
          "email": "",
          "phone": mobile,
          "occupation": "",
          "qualification": "",
          "marital_status": "",
          "profile_image": "",
        });

        await _persistLogin();
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- SESSION ----------------
  Future<void> _persistLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('logged_in') ?? false;

    if (!loggedIn) _user = null;
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

      return response['success'] == true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    _user = null;
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // ---------------- UPDATE PROFILE ----------------
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

  void updateProfileImage(String imagePath) {
    if (_user == null) return;
    _user = _user!.copyWith(profileImage: imagePath);
    notifyListeners();
  }
}
