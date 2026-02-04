import 'api_service.dart';
import '../models/product.dart';

class ProductService {
  // Get all products - API first approach with debugging
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await ApiService.get('products');
      
      // Handle API Resource collection response
      List<dynamic> productsData;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        productsData = response['data'] as List<dynamic>;
      } else if (response is List) {
        productsData = response as List<dynamic>;
      } else {
        throw Exception('Unexpected API response format');
      }
      
      // Log the image paths for debugging
      for (var productData in productsData) {
        final imageData = (productData as Map<String, dynamic>)['image'];
        print('Product image path: $imageData');
        print('Image path type: ${imageData.runtimeType}');
        print('Image path length: ${imageData?.toString().length ?? 0}');
        print('Image path is empty: ${imageData?.toString().isEmpty ?? true}');
        print('Product data keys: ${(productData as Map<String, dynamic>).keys.toList()}');
      }
      
      // Parse products from API data
      return productsData.map((data) => Product.fromJson(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('API Error: $e');
      // Only fallback to sample data on complete failure
      return _getSampleProducts();
    }
  }

  // Get popular products - API first
  static Future<List<Product>> getPopularProducts() async {
    try {
      final response = await ApiService.get('products/popular');
      
      List<dynamic> productsData;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        productsData = response['data'] as List<dynamic>;
      } else if (response is List) {
        productsData = response as List<dynamic>;
      } else {
        // If no popular endpoint, filter from all products
        final allProducts = await getAllProducts();
        return allProducts.where((p) => p.isFeatured).toList();
      }
      
      return productsData.map((data) => Product.fromJson(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Popular products API error: $e');
      // Fallback to featured products from all products
      final allProducts = await getAllProducts();
      return allProducts.where((p) => p.isFeatured).toList();
    }
  }

  // Get featured products - API first
  static Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await ApiService.get('products/featured');
      
      List<dynamic> productsData;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        productsData = response['data'] as List<dynamic>;
      } else if (response is List) {
        productsData = response as List<dynamic>;
      } else {
        // If no featured endpoint, get all products and filter
        final allProducts = await getAllProducts();
        return allProducts.where((p) => p.isFeatured).toList();
      }
      
      return productsData.map((data) => Product.fromJson(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Featured products API error: $e');
      // Fallback to filtering from all products
      final allProducts = await getAllProducts();
      return allProducts.where((p) => p.isFeatured).toList();
    }
  }

  // Private method to get sample products
  static List<Product> _getSampleProducts() {
    return [
      Product(
        id: 1,
        name: 'Golden Latte',
        description:
            'Our signature golden latte with premium espresso and steamed milk',
        price: 850.00,
        image: 'assets/images/golden_latte.png',
        categoryId: 1,
        categoryName: 'Hot Coffee',
        isPopular: true,
        isFeatured: true,
        prepTime: '5-10 min',
        ingredients: ['Espresso', 'Steamed Milk', 'Golden Syrup'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 2,
        name: 'Cappuccino',
        description: 'Espresso with steamed milk foam',
        price: 750.00,
        image: 'assets/images/cappuccino.png',
        categoryId: 1,
        categoryName: 'Hot Coffee',
        isPopular: true,
        isFeatured: false,
        prepTime: '3-5 min',
        ingredients: ['Espresso', 'Steamed Milk', 'Milk Foam'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 3,
        name: 'Iced Latte',
        description: 'Cold version of our signature golden latte',
        price: 900.00,
        image: 'assets/images/latte.png',
        categoryId: 2,
        categoryName: 'Cold Coffee',
        isPopular: true,
        isFeatured: true,
        prepTime: '5-8 min',
        ingredients: ['Espresso', 'Cold Milk', 'Ice', 'Golden Syrup'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
