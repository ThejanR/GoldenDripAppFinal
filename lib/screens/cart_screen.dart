import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/pickme_service.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'checkout_form.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isEmpty) {
              return const EmptyCartView();
            }

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Cart',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${cartProvider.totalItems} items',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ),

                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount:
                        cartProvider.items.length + 1, // +1 for add more button
                    itemBuilder: (context, index) {
                      if (index == cartProvider.items.length) {
                        // Add More Items Button
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: OutlinedButton(
                            onPressed: () {
                              // Navigate to menu - handled by bottom nav
                            },
                            child: const Text('Add More Items'),
                          ),
                        );
                      }

                      final cartItem = cartProvider.items[index];
                      return CartItemCard(
                        cartItem: cartItem,
                        onIncrease: () =>
                            cartProvider.addToCart(cartItem.product),
                        onDecrease: () =>
                            cartProvider.removeFromCart(cartItem.product),
                        onRemove: () =>
                            cartProvider.removeAllOfProduct(cartItem.product),
                      );
                    },
                  ),
                ),

                // Order Summary
                OrderSummaryCard(cartProvider: cartProvider),

                // Place Order Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        _showCheckoutDialog(context, cartProvider);
                      },
                      child: const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, CartProvider cartProvider) {
    // Show the new checkout form
    showDialog(
      context: context,
      builder: (context) => CheckoutForm(
        cartProvider: cartProvider,
        onOrderSuccess: () {
          // Handle successful order placement
          print('Order placed successfully!');
        },
      ),
    );
  }
}

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              // Navigate to menu - handled by bottom nav
            },
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: _buildProductImage(context, cartItem.product),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.totalPriceFormatted,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Row(
              children: [
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 24,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    cartItem.quantity.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle),
                  iconSize: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, Product product) {
    // Try to determine the best image source

    // If it's an HTTP URL, try to load it
    if (product.image.startsWith('http')) {
      return Image.network(
        product.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.coffee,
            size: 30,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          );
        },
      );
    }

    // If it's a local file path, try to load it
    if (product.image.startsWith('/')) {
      try {
        return Image.file(
          File(product.image),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fall back to asset image if file loading fails
            return _buildAssetImage(context, product);
          },
        );
      } catch (e) {
        // Fall back to asset image if file loading fails
        return _buildAssetImage(context, product);
      }
    }

    // Default to asset image
    return _buildAssetImage(context, product);
  }

  Widget _buildAssetImage(BuildContext context, Product product) {
    // Map product names to asset images
    final assetMap = {
      'Golden Latte': 'assets/images/golden_latte.png',
      'Cappuccino': 'assets/images/cappuccino.png',
      'Iced Latte': 'assets/images/latte.png',
      'Classic Espresso': 'assets/images/expresso.png',
      'Flat White': 'assets/images/flat.png',
    };

    final assetPath =
        assetMap[product.name] ?? 'assets/images/golden_latte.png';

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.coffee,
          size: 30,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
      },
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  final CartProvider cartProvider;

  const OrderSummaryCard({
    super.key,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(context, 'Subtotal', cartProvider.subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow(context, 'Tax (8%)', cartProvider.tax),
            const SizedBox(height: 8),
            _buildSummaryRow(context, 'Service Fee', cartProvider.fees),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '\$${cartProvider.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
