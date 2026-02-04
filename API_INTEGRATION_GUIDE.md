# Laravel API Integration Guide for Golden Drip App

## Overview
This guide explains how to connect your Flutter Golden Drip app to a Laravel API backend.

## Prerequisites
1. Laravel API with Sanctum authentication
2. Proper CORS configuration
3. API endpoints matching the service structure

## Setup Steps

### 1. Update API Base URL
In `lib/services/api_service.dart`, update the base URL:
```dart
static const String _baseUrl = 'YOUR_LARAVEL_API_URL/api';
```

### 2. Laravel API Endpoints Required

#### Authentication Endpoints
```
POST /api/login
POST /api/register
POST /api/logout
GET /api/user
PUT /api/user/profile
POST /api/refresh (optional)
```

#### Product Endpoints
```
GET /api/products
GET /api/products/{id}
GET /api/products/category/{category}
GET /api/products/featured
GET /api/products/popular
GET /api/products/search?q={query}
GET /api/categories
```

#### Cart Endpoints
```
GET /api/cart
POST /api/cart
PUT /api/cart/{id}
DELETE /api/cart/{id}
DELETE /api/cart
```

#### Order Endpoints
```
GET /api/orders
GET /api/orders/{id}
POST /api/orders
POST /api/orders/{id}/cancel
GET /api/orders/{id}/track
GET /api/orders/statuses
```

### 3. Laravel API Response Format
Your Laravel API should return JSON in this format:

**Success Response:**
```json
{
  "success": true,
  "data": {...},
  "message": "Operation successful"
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description",
  "errors": {...}
}
```

### 4. Authentication Flow
1. User logs in via `/api/login`
2. API returns auth token
3. Token is stored locally using `shared_preferences`
4. Token is automatically included in subsequent requests
5. Token is cleared on logout

### 5. Implementation Examples

#### Login Integration
Replace the `_handleLogin()` method in `login_screen.dart`:

```dart
import 'package:your_app/services/auth_service.dart';

void _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Login successful
      widget.onLoginSuccess();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

#### Product Listing Integration
Update your home screen to fetch products from API:

```dart
import 'package:your_app/services/product_service.dart';

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productsData = await ProductService.getAllProducts();
      setState(() {
        _products = productsData.map((data) => Product.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: ${e.toString()}')),
      );
    }
  }
}
```

### 6. Model Classes
Create model classes to parse API responses:

**Product Model Example:**
```dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isPopular;
  final String prepTime;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.isPopular,
    required this.prepTime,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image_url'] ?? json['image'],
      category: json['category'],
      isPopular: json['is_popular'] ?? false,
      prepTime: json['prep_time'] ?? '5-10 min',
    );
  }
}
```

### 7. Error Handling
The API service includes built-in error handling. Catch `ApiException` for specific error handling:

```dart
try {
  final result = await SomeService.someMethod();
} on ApiException catch (e) {
  if (e.statusCode == 401) {
    // Handle unauthorized access
    // Redirect to login
  } else if (e.statusCode == 422) {
    // Handle validation errors
    // Show error messages
  }
} catch (e) {
  // Handle network errors
}
```

### 8. Testing
1. Update the base URL to point to your local/test API
2. Test each service method individually
3. Verify authentication flow
4. Test error scenarios

### 9. Production Deployment
1. Update base URL to production API
2. Ensure HTTPS is used in production
3. Configure proper error logging
4. Set up monitoring for API calls

## Need Help?
- Check the console logs for detailed API request/response information
- Ensure your Laravel API CORS settings allow your Flutter app origin
- Verify authentication token is being sent with protected requests