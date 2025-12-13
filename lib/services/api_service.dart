// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // CHANGE this to your backend URL.
  // For Android emulator use: http://10.0.2.2:5000
  // For iOS simulator use: http://localhost:5000
  // For real device use: http://<your-machine-ip>:5000
  static const String baseUrl = "http://10.0.2.2:5000";

  // Generic helper to decode body safely
  static Map<String, dynamic> _decodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {"success": false, "message": "Invalid response from server"};
    }
  }

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return _decodeBody(res.body);
  }

  // ---------------- SIGNUP ----------------
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/signup");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return _decodeBody(res.body);
  }
}
