import 'dart:convert';
import 'package:http/http.dart' as http;
import '/api/auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://152.67.5.32';

  // Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 401) {
        // Token expired or invalid
        throw UnauthorizedException(
          'Your session has expired. Please log in again.',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('GET request error: $e');
      rethrow;
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: AuthService.getAuthHeaders(),
        body: json.encode(data),
      );

      if (response.statusCode == 401) {
        // Token expired or invalid
        throw UnauthorizedException(
          'Your session has expired. Please log in again.',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('POST request error: $e');
      rethrow;
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}
