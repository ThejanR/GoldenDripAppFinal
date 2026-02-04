class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String? imagePath; // New field for local asset path
  final int categoryId;
  final String categoryName;
  final bool isPopular;
  final bool isFeatured;
  final String prepTime;
  final List<String> ingredients;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.imagePath, // Optional field
    required this.categoryId,
    required this.categoryName,
    required this.isPopular,
    required this.isFeatured,
    required this.prepTime,
    required this.ingredients,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String? ?? '',
      imagePath: json['image_path'] as String?, // New field,
      categoryId: 0, // Not provided in API
      categoryName: json['category'] as String? ?? 'General',
      isPopular: json['is_popular'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ??
          _isDefaultFeatured(json['name'] as String?),
      prepTime: '5-10 min', // Default value
      ingredients: [], // Not provided in API
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Helper method to determine if a product should be featured by default
  static bool _isDefaultFeatured(String? productName) {
    if (productName == null) return false;
    // Mark certain popular products as featured by default
    final featuredNames = [
      'Golden Latte',
      'Cappuccino',
      'Iced Latte',
      'Espresso',
      'Flat White',
      'Classic Cappuccino',
      'Caffè Latte'
    ];
    return featuredNames
        .any((name) => productName.toLowerCase().contains(name.toLowerCase()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'image_path': imagePath,
      'category': categoryName,
      'is_popular': isPopular,
      'is_featured': isFeatured,
    };
  }

  String get priceFormatted => '\$${price.toStringAsFixed(2)}';
  String get imageAsset {
    // If we have a direct image path from the API, use it
    if (imagePath != null && imagePath!.isNotEmpty) {
      return 'assets/$imagePath';
    }

    // If the image is already an asset path, return it
    if (image.startsWith('assets/')) {
      return image;
    }

    // If it's a network URL, try to map the product name to a local asset
    if (image.startsWith('http')) {
      final assetMap = {
        'Golden Latte': 'assets/images/golden_latte.png',
        'Classic Cappuccino': 'assets/images/cappuccino.png',
        'Caffè Latte': 'assets/images/latte.png',
        'Espresso': 'assets/images/expresso.png',
        'Flat White': 'assets/images/flat.png',
        'Cappuccino': 'assets/images/cappuccino.png',
        'Iced Latte': 'assets/images/latte.png',
        'Mocha': 'assets/images/mocha.png',
        'Macchiato': 'assets/images/macchiato.png',
        'Americano': 'assets/images/americano.png',
        'Iced Americano': 'assets/images/iced_americano.png',
        'Frappé': 'assets/images/cold.png',
        'Frappe': 'assets/images/cold.png',
        'Iced Coffee': 'assets/images/cold.png',
        'Cold Brew': 'assets/images/cold.png',
        'Shake': 'assets/images/vanillashake.png',
        'Chocolate Shake': 'assets/images/coffeeshake.png',
        'Coffee Shake': 'assets/images/coffeeshake.png',
        'Strawberry Shake': 'assets/images/strawberry.png',
        'Vanilla Shake': 'assets/images/vanillashake.png',
        'Croissant': 'assets/images/buttercro.png',
        'Chocolate Croissant': 'assets/images/choccro.png',
        'Muffin': 'assets/images/chocomuffin.png',
        'Chocolate Muffin': 'assets/images/chocomuffin.png',
        'Blueberry Muffin': 'assets/images/chocomuffin.png',
        'Donut': 'assets/images/chocodo.png',
        'Chocolate Donut': 'assets/images/chocodo.png',
        'Glazed Donut': 'assets/images/glazeddo.png',
        'Strawberry Donut': 'assets/images/strawdo.png',
        'Caramel Croissant': 'assets/images/choccro.png',
        'Hot Chocolate': 'assets/images/coffeeshake.png',
      };

      // Try to find a matching asset based on the product name
      for (final entry in assetMap.entries) {
        if (name.toLowerCase().contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }

      // Check for partial matches
      if (name.toLowerCase().contains('shake')) {
        return 'assets/images/vanillashake.png';
      } else if (name.toLowerCase().contains('donut')) {
        return 'assets/images/chocodo.png';
      } else if (name.toLowerCase().contains('croissant')) {
        return 'assets/images/buttercro.png';
      } else if (name.toLowerCase().contains('muffin') ||
          name.toLowerCase().contains('muffin')) {
        return 'assets/images/chocomuffin.png';
      } else if (name.toLowerCase().contains('coffee') ||
          name.toLowerCase().contains('frapp') ||
          name.toLowerCase().contains('ice') ||
          name.toLowerCase().contains('cold')) {
        return 'assets/images/cold.png';
      } else if (name.toLowerCase().contains('chocolate') ||
          name.toLowerCase().contains('choco')) {
        return 'assets/images/chocodo.png';
      } else if (name.toLowerCase().contains('strawberry')) {
        return 'assets/images/strawdo.png';
      } else if (name.toLowerCase().contains('caramel')) {
        return 'assets/images/choccro.png';
      }

      // Default fallback
      return 'assets/images/golden_latte.png';
    }

    // For local file paths
    if (image.startsWith('/')) {
      return image;
    }

    // Return as-is if it's already an asset path
    return image;
  }
}

// Compatibility class for existing code
class ProductDataSource {
  static List<Product> getProducts() {
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
      Product(
        id: 4,
        name: 'Classic Espresso',
        description: 'Strong espresso shot brewed from premium beans',
        price: 600.00,
        image: 'assets/images/expresso.png',
        categoryId: 1,
        categoryName: 'Hot Coffee',
        isPopular: false,
        isFeatured: false,
        prepTime: '2-3 min',
        ingredients: ['Premium Coffee Beans'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 5,
        name: 'Flat White',
        description: 'Smooth espresso with microfoam milk',
        price: 800.00,
        image: 'assets/images/flat.png',
        categoryId: 1,
        categoryName: 'Hot Coffee',
        isPopular: false,
        isFeatured: false,
        prepTime: '4-6 min',
        ingredients: ['Espresso', 'Microfoam Milk'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<String> getCategories() {
    return ['All', 'Hot Coffee', 'Cold Coffee'];
  }
}
