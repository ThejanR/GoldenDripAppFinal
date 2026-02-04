import 'package:url_launcher/url_launcher.dart';

class PickMeService {
  // PickMe app deep link URL schemes
  static const String _pickMeAppUrl = 'pickme://';
  static const String _pickMeWebUrl = 'https://www.pickme.lk/';

  /// Check if PickMe app is installed on the device
  static Future<bool> isPickMeInstalled() async {
    try {
      final uri = Uri.parse(_pickMeAppUrl);
      final canLaunch = await canLaunchUrl(uri);
      return canLaunch;
    } catch (e) {
      // If the app isn't installed, attempting to launch will fail gracefully
      return false;
    }
  }

  /// Launch PickMe app with delivery details
  static Future<bool> launchPickMeDelivery({
    required String pickupLocation,
    required String dropoffLocation,
    String? customerName,
    String? customerPhone,
    String? deliveryNotes,
  }) async {
    try {
      // Construct the deep link with order details
      final params = <String, String>{
        'pickup': pickupLocation,
        'dropoff': dropoffLocation,
        if (customerName != null) 'customerName': customerName,
        if (customerPhone != null) 'customerPhone': customerPhone,
        if (deliveryNotes != null) 'notes': deliveryNotes,
      };

      final uri = Uri.parse(_pickMeAppUrl).replace(queryParameters: params);

      // Try to launch the app
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // If the app isn't installed or launching failed, fall back to web
      if (!launched) {
        return await _fallbackToWeb(deliveryNotes: deliveryNotes);
      }

      return launched;
    } catch (e) {
      print('Error launching PickMe: $e');
      // Fallback to web if direct launch fails
      return await _fallbackToWeb(deliveryNotes: deliveryNotes);
    }
  }

  /// Fallback to web version if app isn't available
  static Future<bool> _fallbackToWeb({String? deliveryNotes}) async {
    try {
      final uri = Uri.parse(_pickMeWebUrl);
      return await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } catch (e) {
      print('Error launching PickMe web: $e');
      return false;
    }
  }

  /// Launch PickMe app directly for ride booking
  static Future<bool> launchPickMeRide({
    String? pickupLocation,
    String? dropoffLocation,
  }) async {
    try {
      final params = <String, String>{};
      if (pickupLocation != null) params['pickup'] = pickupLocation;
      if (dropoffLocation != null) params['dropoff'] = dropoffLocation;

      final uri = Uri.parse(_pickMeAppUrl).replace(queryParameters: params);

      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error launching PickMe ride: $e');
      return await _fallbackToWeb();
    }
  }
}
