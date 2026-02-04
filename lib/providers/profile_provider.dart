import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class ProfileProvider extends ChangeNotifier {
  File? _profileImage;
  User? _user;
  bool _isLoading = false;

  File? get profileImage => _profileImage;
  User? get user => _user;
  bool get isLoading => _isLoading;

  // Load user profile from API
  Future<void> loadUserProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await UserService.getCurrentUser();
      _user = user;

      // If user has a profile image URL, we might want to download it
      // For now, we'll just clear the local image if user data changes
      if (_user?.profileImage != null) {
        _profileImage = null; // Clear local image to use API image
      }
    } catch (e) {
      print('Failed to load user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfileImage(File image) {
    _profileImage = image;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileImage = null;
    notifyListeners();
  }

  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await UserService.updateUserProfile(data);
      _user = updatedUser;
    } catch (e) {
      print('Failed to update user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile image via API
  Future<void> updateProfileImageApi(String imagePath) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await UserService.updateProfileImage(imagePath);
      _user = updatedUser;
      _profileImage = null; // Clear local image to use API image
    } catch (e) {
      print('Failed to update profile image via API: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
