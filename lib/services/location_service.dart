import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Request permission using permission_handler
  static Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  // Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    var status = await Permission.location.status;
    return status.isGranted;
  }

  // Open app settings to enable permission
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Get location as string (latitude, longitude)
  static Future<String> getLocationString() async {
    try {
      Position position = await getCurrentPosition();
      return '${position.latitude}, ${position.longitude}';
    } catch (e) {
      rethrow;
    }
  }

  // Calculate distance between two points
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
