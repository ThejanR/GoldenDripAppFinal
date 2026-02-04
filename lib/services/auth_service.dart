import 'api_service.dart';

class AuthService {
  // User login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('login', {
        'email': email,
        'password': password,
      });

      print('Login response: $response');

      // Save the auth token if login successful
      if (response.containsKey('token')) {
        await ApiService.saveAuthToken(response['token']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // User registration
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiService.post('register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      // Save the auth token if registration successful
      if (response.containsKey('token')) {
        await ApiService.saveAuthToken(response['token']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // User logout
  static Future<void> logout() async {
    try {
      await ApiService.post('logout', {});
      await ApiService.clearAuthToken();
    } catch (e) {
      // Even if logout fails, clear local token
      await ApiService.clearAuthToken();
      rethrow;
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      return await ApiService.get('user');
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;

      return await ApiService.put('user/profile', data);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => ApiService.isAuthenticated;

  // Refresh auth token (if your Laravel API supports it)
  static Future<void> refreshToken() async {
    try {
      final response = await ApiService.post('refresh', {});
      if (response.containsKey('token')) {
        await ApiService.saveAuthToken(response['token']);
      }
    } catch (e) {
      // If refresh fails, clear the token
      await ApiService.clearAuthToken();
      rethrow;
    }
  }
}
