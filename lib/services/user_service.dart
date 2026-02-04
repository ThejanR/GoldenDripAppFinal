import 'api_service.dart';
import '../models/user.dart';
import 'auth_service.dart';

class UserService {
  static Map<String, dynamic>? _cachedUserData;

  // Cache user data from login response
  static void cacheUserData(Map<String, dynamic> userData) {
    _cachedUserData = userData;
    print('Cached user data: $userData');
  }

  // Clear cached user data
  static void clearCachedUserData() {
    _cachedUserData = null;
  }

  static Future<User> getCurrentUser() async {
    // First check if we have cached user data from login
    if (_cachedUserData != null) {
      print('Using cached user data');
      return User.fromJson(_cachedUserData!);
    }

    try {
      // First try the standard user endpoint
      final response = await ApiService.get('user');
      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Failed to fetch user profile from /api/user: $e');

      // Try the profile endpoint as fallback
      try {
        final response = await ApiService.get('user/profile');
        return User.fromJson(response as Map<String, dynamic>);
      } catch (e2) {
        print('Failed to fetch user profile from /api/user/profile: $e2');

        // Return a default user if API fails
        return User(
          id: 0,
          name: 'Guest User',
          email: 'guest@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  // Update user profile
  static Future<User> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('user/profile', data);
      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Failed to update user profile: $e');
      rethrow;
    }
  }

  // Update user profile image
  static Future<User> updateProfileImage(String imagePath) async {
    try {
      final data = {'profile_image': imagePath};
      final response = await ApiService.post('user/profile-image', data);
      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Failed to update profile image: $e');
      rethrow;
    }
  }
}
