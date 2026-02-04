import 'api_service.dart';

class OrderService {
  // Get user's order history
  static Future<List<dynamic>> getOrderHistory() async {
    try {
      final response = await ApiService.get('orders');
      return response['data'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Get single order details
  static Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      return await ApiService.get('orders/$orderId');
    } catch (e) {
      rethrow;
    }
  }

  // Create new order from cart
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String deliveryMethod,
    String? deliveryAddress,
    String? deliveryInstructions,
    String? paymentMethod = 'cash',
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      final data = {
        'items': items,
        'total': total,
        'payment_method': paymentMethod,
        'delivery_method': null, // Send null to avoid database error
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        if (deliveryInstructions != null)
          'delivery_instructions': deliveryInstructions,
        if (customerName != null) 'customer_name': customerName,
        if (customerPhone != null) 'customer_phone': customerPhone,
      };

      print('=== ORDER CREATION DEBUG ===');
      print('Sending order data: $data');
      print('API endpoint: orders');
      print('============================');

      final result = await ApiService.post('orders', data);
      print('Order creation successful: $result');
      return result;
    } catch (e) {
      print('=== ORDER CREATION ERROR ===');
      print('Error creating order: $e');
      print('Error type: ${e.runtimeType}');
      print('============================');
      rethrow;
    }
  }

  // Cancel order
  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      return await ApiService.post('orders/$orderId/cancel', {});
    } catch (e) {
      rethrow;
    }
  }

  // Track order status
  static Future<Map<String, dynamic>> trackOrder(int orderId) async {
    try {
      return await ApiService.get('orders/$orderId/track');
    } catch (e) {
      rethrow;
    }
  }

  // Get order status options
  static Future<List<dynamic>> getOrderStatuses() async {
    try {
      final response = await ApiService.get('orders/statuses');
      return response['data'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
