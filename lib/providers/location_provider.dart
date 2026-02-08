import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLocationEnabled = false;
  bool _isPermissionGranted = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isPermissionGranted => _isPermissionGranted;
  String get locationString => _currentPosition != null
      ? '${_currentPosition!.latitude}, ${_currentPosition!.longitude}'
      : 'Location not available';

  // Check if location services are enabled
  Future<void> checkLocationService() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isLocationEnabled = await LocationService.isLocationServiceEnabled();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check and request location permission
  Future<void> checkAndRequestPermission() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First check with geolocator
      LocationPermission permission = await LocationService.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await LocationService.requestPermission();
      }

      // Also check with permission_handler for better UX
      bool isGranted = await LocationService.isLocationPermissionGranted();
      _isPermissionGranted = isGranted;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await checkLocationService();
      if (!_isLocationEnabled) {
        _errorMessage =
            'Location services are disabled. Please enable them in your device settings.';
        notifyListeners();
        return;
      }

      await checkAndRequestPermission();
      if (!_isPermissionGranted) {
        _errorMessage =
            'Location permission is required to get your current location.';
        notifyListeners();
        return;
      }

      _currentPosition = await LocationService.getCurrentPosition();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _currentPosition = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get location as string
  Future<String> getLocationString() async {
    try {
      return await LocationService.getLocationString();
    } catch (e) {
      rethrow;
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return LocationService.calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Reset error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _currentPosition = null;
    _errorMessage = null;
    _isLoading = false;
    _isLocationEnabled = false;
    _isPermissionGranted = false;
    notifyListeners();
  }
}
