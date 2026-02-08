import 'api_service.dart';
import '../models/order.dart';

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

  // Get user's order history
  static Future<List<Order>> getUserOrders() async {
    try {
      final response =
          await ApiService.get('orders'); // Try basic orders endpoint
      print('Orders API Response Type: ${response.runtimeType}');
      print('Orders API Response: $response');

      // Handle empty responses
      if (response == null || (response is String && response.isEmpty)) {
        print('Received empty response from orders API');
        return [];
      }

      // Simple approach - try to get list of orders
      List<dynamic> orderDataList = [];

      if (response is List) {
        orderDataList = response as List;
      } else if (response is Map<String, dynamic>) {
        // Try common keys for order lists
        if (response.containsKey('data') && response['data'] is List) {
          orderDataList = response['data'] as List;
        } else if (response.containsKey('orders') &&
            response['orders'] is List) {
          orderDataList = response['orders'] as List;
        } else {
          // Single order - wrap in list
          orderDataList = [response];
        }
      }

      // Convert to Order objects
      final List<Order> orders = [];
      for (var item in orderDataList) {
        if (item is Map<String, dynamic>) {
          try {
            final order = Order.fromJson(item);
            if (order.total <= 0) {
              print('WARNING: Order #${order.id} parsed with 0 total. Raw item data: $item');
            }
            orders.add(order);
            print('Successfully parsed order #${order.id} with total: ${order.total}');
          } catch (e) {
            print('Failed to parse order item: $e');
            print('Item data: $item');
          }
        }
      }

      print('Successfully loaded ${orders.length} orders');
      return orders;
    } catch (e) {
      print('Error in getUserOrders: $e');
      return [];
    }
  }
}
