import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // ================= BASE CONFIG =================
  static const String baseUrl = "http://10.0.2.2:5000";

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  static const Duration _timeout = Duration(seconds: 10);

  // ================= SIGNUP =================
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/signup"),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      return _networkError();
    } on FormatException {
      return _formatError();
    } catch (_) {
      return _unknownError();
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // ================= DOCUMENT UPLOAD (OCR) =================
  static Future<Map<String, dynamic>> uploadDocument(File file) async {
    try {
      final uri = Uri.parse("$baseUrl/upload-document");

      final request = http.MultipartRequest("POST", uri);

      // IMPORTANT: field name must be "file"
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final streamedResponse = await request.send().timeout(_timeout);

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Document upload failed"};
      }
    } on SocketException {
      return _networkError();
    } on FormatException {
      return _formatError();
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ================= RESPONSE HANDLER =================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"success": false, "message": body["message"] ?? "Request failed"};
    } catch (_) {
      return _formatError();
    }
  }

  // ================= ERROR HELPERS =================
  static Map<String, dynamic> _networkError() {
    return {
      "success": false,
      "message": "Unable to connect to server. Check backend or network.",
    };
  }

  static Map<String, dynamic> _formatError() {
    return {"success": false, "message": "Invalid response from server."};
  }

  static Map<String, dynamic> _unknownError() {
    return {
      "success": false,
      "message": "Something went wrong. Please try again.",
    };
  }

  // ================= EXISTING SCHEME SEARCH (WORKING) =================
  static Future<List<dynamic>> searchSchemes(String query) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/schemes/search"),
            headers: _headers,
            body: jsonEncode({"query": query}),
          )
          .timeout(_timeout);
      print("SEARCH STATUS: ${response.statusCode}");
      print("SEARCH RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getSchemeDetails(String title) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/schemes/details"),
            headers: _headers,
            body: jsonEncode({"title": title}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<dynamic>> getSchemesByCategory(String category) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/schemes/category"),
            headers: _headers,
            body: jsonEncode({"category": category}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<dynamic>> getCarouselSchemes() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/schemes/carousel"), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ================= NEW PROJECT FOLDER API METHODS =================
  // Search API from PROJECT folder
  static Future<List<dynamic>> projectSearchSchemes(String query) async {
    final response = await http.post(
      Uri.parse("$baseUrl/search"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": query}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to search schemes (PROJECT)");
    }
  }

  // Category API from PROJECT folder
  static Future<List<dynamic>> projectGetSchemesByCategory(
    String category,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/category"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"category": category}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load category schemes (PROJECT)");
    }
  }

  // Single Scheme Details API from PROJECT folder
  static Future<Map<String, dynamic>> projectGetSchemeDetails(
    String title,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/scheme"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title.trim()}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Scheme not found (PROJECT)");
    }
  }

  // Carousel API from PROJECT folder
  static Future<List<dynamic>> projectGetCarouselTitles() async {
    final response = await http.get(Uri.parse("$baseUrl/carousel"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load carousel (PROJECT)");
    }
  }
}
