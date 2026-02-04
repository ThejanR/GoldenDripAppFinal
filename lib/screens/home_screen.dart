import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/temperature_provider.dart';
import '../providers/profile_provider.dart';
import '../services/product_service.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _popularProducts = [];
  List<Product> _recommendedProducts = [];
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _startTemperatureMonitoring();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load products from API
      final popularProducts = await ProductService.getPopularProducts();
      final allProducts = await ProductService.getAllProducts();

      // Get recommended categories based on temperature
      final temperatureProvider =
          Provider.of<TemperatureProvider>(context, listen: false);
      final recommendedCategories =
          temperatureProvider.getRecommendedCategories();
      final recommendedProducts = allProducts
          .where(
              (product) => recommendedCategories.contains(product.categoryName))
          .take(3)
          .toList();

      setState(() {
        _popularProducts = popularProducts;
        _allProducts = allProducts;
        _recommendedProducts = recommendedProducts;
        _isLoading = false;
      });
      
      // Debug logging
      print('Loaded ${popularProducts.length} popular products');
      for (var product in popularProducts) {
        print('Popular product: ${product.name}, isPopular: ${product.isPopular}');
      }
      
      // Fallback: if no popular products, show featured products as popular
      if (popularProducts.isEmpty) {
        print('No popular products found, using featured products as fallback');
        final featuredProducts = allProducts.where((p) => p.isFeatured).toList();
        if (featuredProducts.isNotEmpty) {
          print('Using ${featuredProducts.length} featured products as popular');
          setState(() {
            _popularProducts = featuredProducts;
          });
        } else {
          // Last resort: show first 3 products as popular
          print('No featured products found, using first 3 products as popular');
          final firstProducts = allProducts.take(3).toList();
          setState(() {
            _popularProducts = firstProducts;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load products: ${e.toString()}';
      });
    }
  }

  void _startTemperatureMonitoring() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final temperatureProvider =
          Provider.of<TemperatureProvider>(context, listen: false);
      temperatureProvider.startTemperatureMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    final temperatureProvider = Provider.of<TemperatureProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading products...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: profileProvider.profileImage != null
                        ? FileImage(profileProvider.profileImage!)
                            as ImageProvider
                        : (profileProvider.user?.profileImage
                                    ?.startsWith('http') ??
                                false)
                            ? NetworkImage(profileProvider.user!.profileImage!)
                            : null,
                    child: profileProvider.profileImage == null &&
                            !(profileProvider.user?.profileImage
                                    ?.startsWith('http') ??
                                false)
                        ? Icon(
                            Icons.person,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Welcome Back, ${profileProvider.user?.name?.split(' ').first ?? 'Guest'}!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Temperature Recommendation Card
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.thermostat,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today\'s Recommendation',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        temperatureProvider.temperatureRecommendation,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (temperatureProvider.currentTemperature != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Current device temperature: ${temperatureProvider.currentTemperature!.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recommended Products based on temperature
              if (_recommendedProducts.isNotEmpty) ...[
                Text(
                  'Recommended for You',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ..._recommendedProducts
                    .map((product) => ProductListTile(product: product)),
                const SizedBox(height: 24),
              ],

              // Fast Moving Products Section
              Text(
                'Popular Items',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Popular Products List
              ..._popularProducts
                  .map((product) => ProductListTile(product: product)),

              const SizedBox(height: 32),

              // Coffee Carousel
              Text(
                'Featured',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 220,
                child: PageView(
                  children: [
                    _buildCoffeeSlide(
                      context,
                      'assets/images/cappuccino.png',
                      'Cappuccino',
                      'Espresso with steamed milk foam',
                    ),
                    _buildCoffeeSlide(
                      context,
                      'assets/images/latte.png',
                      'Iced Latte',
                      'Cold version of our signature golden latte',
                    ),
                    _buildCoffeeSlide(
                      context,
                      'assets/images/expresso.png',
                      'Classic Espresso',
                      'Strong espresso shot brewed from premium beans',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Customer Reviews
              Text(
                'Customer Reviews',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sarah Johnson',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          ...List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amazing coffee! The Golden Latte is my favorite. '
                        'Great service and cozy atmosphere.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a coffee slide
  Widget _buildCoffeeSlide(BuildContext context, String imagePath, String title,
      String description) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Icon(
                                Icons.coffee,
                                size: 50,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            );
                          },
                        )
                      : imagePath.startsWith('/')
                          ? Image.file(
                              File(imagePath),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Icon(
                                    Icons.coffee,
                                    size: 50,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              imagePath,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Icon(
                                    Icons.coffee,
                                    size: 50,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;

  const ProductListTile({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: _buildProductImage(context, product),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceFormatted,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    // Add to cart functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(Icons.add_shopping_cart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, Product product) {
    print('Building image for product: ${product.name}, image path: ${product.image}, asset path: ${product.imageAsset}');
    
    // First try to load the network image
    if (product.image.startsWith('http')) {
      print('Loading image from network: ${product.image}');
      return Image.network(
        product.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load network image: $error');
          print('Falling back to asset image: ${product.imageAsset}');
          // On network failure, fall back to the mapped asset image
          return Image.asset(
            product.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Failed to load asset image: $error');
              return Icon(
                Icons.coffee,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              );
            },
          );
        },
      );
    } else {
      // If it's not a network image, load it directly
      try {
        if (product.image.startsWith('/')) {
          return Image.file(
            File(product.image),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Failed to load file image: $error');
              return Image.asset(
                product.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Failed to load asset image: $error');
                  return Icon(
                    Icons.coffee,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  );
                },
              );
            },
          );
        } else {
          return Image.asset(
            product.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Failed to load asset image: $error');
              return Image.asset(
                product.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Failed to load fallback asset image: $error');
                  return Icon(
                    Icons.coffee,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  );
                },
              );
            },
          );
        }
      } catch (e) {
        print('Exception loading image: $e');
        // Final fallback to the mapped asset
        return Image.asset(
          product.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Failed to load final fallback asset image: $error');
            return Icon(
              Icons.coffee,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          },
        );
      }
    }
  }

}
