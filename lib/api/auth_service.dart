import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Replace with your actual API endpoint
  static const String apiUrl = 'http://152.67.5.32/api/auth/';
  static const String baseUrl = 'http://152.67.5.32';

  // Key for storing token in SharedPreferences
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Global token variables
  static String? _accessToken;
  // Store but don't use for refresh

  // Getters for tokens
  static String? get accessToken => _accessToken;

  // Method to login and validate credentials
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract tokens from response
        final accessToken = data['access'];
        final refreshToken = data['refresh'];

        if (accessToken != null) {
          // Save tokens to both global variables and persistent storage
          _accessToken = accessToken;
          // Store for future use if needed
          await _saveTokens(accessToken, refreshToken);
          return true;
        }
      }

      return false;
    } catch (e) {
      print('API call error: $e');
      return false;
    }
  }

  // Method to save tokens to SharedPreferences
  static Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Method to load tokens from SharedPreferences
  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(accessTokenKey);
  }

  // Method to clear tokens on logout
  static Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }

  // Helper method to get auth headers for other API calls
  static Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }
}
