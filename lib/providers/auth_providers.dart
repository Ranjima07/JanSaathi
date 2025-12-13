// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool isLoading = false;
  String? userToken;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      isLoading = false;

      if (response['success'] == true) {
        userToken = response['token'] as String?;
        // persist token
        final prefs = await SharedPreferences.getInstance();
        if (userToken != null) await prefs.setString('token', userToken!);

        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.signup(name, email, password);
      isLoading = false;

      if (response['success'] == true) {
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
