import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // TODO: Update with your Laravel API base URL
  static const String _baseUrl = 'http://13.48.42.101/api';

  static const String _authTokenKey = 'auth_token';
  static String? _authToken;

  // Initialize the service
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_authTokenKey);
  }

  // Get authorization header
  static Map<String, String> get _authHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Save auth token
  static Future<void> saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  // Clear auth token
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  // Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = '$_baseUrl/$endpoint';
      if (kDebugMode) {
        print('GET Request: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _authHeaders,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('GET Error: $e');
      }
      rethrow;
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = '$_baseUrl/$endpoint';
      if (kDebugMode) {
        print('POST Request: $url');
        print('POST Data: $data');
        print('Auth Token Present: ${_authToken != null}');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: _authHeaders,
        body: jsonEncode(data),
      );

      if (kDebugMode) {
        print('POST Response Status: ${response.statusCode}');
        print('POST Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('POST Error: $e');
        print('Error Type: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  // Generic PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = '$_baseUrl/$endpoint';
      if (kDebugMode) {
        print('PUT Request: $url');
        print('Data: $data');
      }

      final response = await http.put(
        Uri.parse(url),
        headers: _authHeaders,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('PUT Error: $e');
      }
      rethrow;
    }
  }

  // Generic DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = '$_baseUrl/$endpoint';
      if (kDebugMode) {
        print('DELETE Request: $url');
      }

      final response = await http.delete(
        Uri.parse(url),
        headers: _authHeaders,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('DELETE Error: $e');
      }
      rethrow;
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    try {
      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        throw ApiException(
          message: responseBody['message'] ?? 'Request failed',
          statusCode: response.statusCode,
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Response parsing error: $e');
        print('Raw response: ${response.body}');
      }
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Invalid response format: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
