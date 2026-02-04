import 'api_service.dart';

class CartService {
  // Get current user's cart
  static Future<Map<String, dynamic>> getCart() async {
    try {
      return await ApiService.get('cart');
    } catch (e) {
      rethrow;
    }
  }

  // Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
    Map<String, dynamic>? options,
  }) async {
    try {
      final data = {
        'product_id': productId,
        'quantity': quantity,
        if (options != null) 'options': options,
      };

      return await ApiService.post('cart', data);
    } catch (e) {
      rethrow;
    }
  }

  // Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      return await ApiService.put('cart/$cartItemId', {
        'quantity': quantity,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove item from cart
  static Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    try {
      return await ApiService.delete('cart/$cartItemId');
    } catch (e) {
      rethrow;
    }
  }

  // Clear entire cart
  static Future<Map<String, dynamic>> clearCart() async {
    try {
      return await ApiService.delete('cart');
    } catch (e) {
      rethrow;
    }
  }

  // Get cart total
  static Future<double> getCartTotal() async {
    try {
      final cart = await getCart();
      return (cart['total'] as num).toDouble();
    } catch (e) {
      rethrow;
    }
  }

  // Get cart item count
  static Future<int> getCartItemCount() async {
    try {
      final cart = await getCart();
      return cart['items_count'] as int? ?? 0;
    } catch (e) {
      rethrow;
    }
  }
}
