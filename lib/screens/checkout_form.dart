import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/pickme_service.dart';
import 'dart:async';

class CheckoutForm extends StatefulWidget {
  final CartProvider cartProvider;
  final VoidCallback onOrderSuccess;

  const CheckoutForm({
    Key? key,
    required this.cartProvider,
    required this.onOrderSuccess,
  }) : super(key: key);

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedDeliveryMethod = 'pickup';
  String _selectedPaymentMethod = 'cash';
  bool _isLoading = false; // Add this to track loading state

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Checkout'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Delivery Method
              const Text('Delivery Method:'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'pickup',
                    label: Text('Pickup'),
                  ),
                  ButtonSegment(
                    value: 'delivery',
                    label: Text('Delivery'),
                  ),
                ],
                selected: {_selectedDeliveryMethod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedDeliveryMethod = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Delivery Address (only if delivery selected)
              if (_selectedDeliveryMethod == 'delivery')
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_selectedDeliveryMethod == 'delivery' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter delivery address';
                    }
                    return null;
                  },
                ),
              if (_selectedDeliveryMethod == 'delivery')
                const SizedBox(height: 16),

              // Special Instructions
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Payment Method
              const Text('Payment Method:'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'cash',
                    label: Text('Cash'),
                  ),
                  ButtonSegment(
                    value: 'card',
                    label: Text('Card'),
                  ),
                  ButtonSegment(
                    value: 'pickme',
                    label: Text('PickMe'),
                  ),
                ],
                selected: {_selectedPaymentMethod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedPaymentMethod = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitOrder,
          child: const Text('Place Order'),
        ),
      ],
    );
  }

  void _submitOrder() async {
    print('=== SUBMIT ORDER STARTED ===');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }
    print('Form validation passed');

    // Handle PickMe delivery option
    if (_selectedPaymentMethod == 'pickme') {
      print('Handling PickMe delivery');
      _handlePickMeDelivery();
      return;
    }
    print('Handling regular order');

    try {
      // Close the form dialog first
      if (mounted) {
        Navigator.pop(context);
      }

      // Show loading indicator
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      print('=== ORDER PROCESSING DEBUG ===');
      print('Customer Name: ${_nameController.text}');
      print('Phone: ${_phoneController.text}');
      print('Delivery Method: $_selectedDeliveryMethod');
      print('Payment Method: $_selectedPaymentMethod');
      print('Auth token present: ${ApiService.isAuthenticated}');

      // Prepare cart items for API
      final items = widget.cartProvider.items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
                'name': item.product.name,
              })
          .toList();

      // Add timeout to prevent infinite loading
      final timeout = Duration(seconds: 15);
      print('Calling OrderService.createOrder');
      final response = await OrderService.createOrder(
        items: items,
        total: widget.cartProvider.total,
        deliveryMethod: _selectedDeliveryMethod,
        paymentMethod: _selectedPaymentMethod,
        deliveryAddress: _selectedDeliveryMethod == 'delivery'
            ? _addressController.text
            : null,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        deliveryInstructions: _instructionsController.text,
      ).timeout(timeout);
      print('OrderService.createOrder completed successfully');

      // Close loading dialog
      print('Closing loading dialog');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Clear cart and show success
      print('Clearing cart');
      widget.cartProvider.clearCart();
      print('Showing success message');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedDeliveryMethod == 'pickup'
                ? 'Order placed successfully! Please pick up your order in 15 minutes.'
                : 'Order placed successfully! Our delivery team will contact you.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
      print('Calling success callback');
      // Call the success callback
      widget.onOrderSuccess();
      print('Order process completed successfully');
    } catch (e) {
      print('=== ERROR IN SUBMIT ORDER ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');

      // Close any open dialogs
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Show error message
      String errorMessage = 'Failed to place order';
      if (e is TimeoutException) {
        errorMessage = 'Order request timed out. Please try again.';
      } else if (e.toString().contains('Invalid response format') &&
          e.toString().contains('FormatException')) {
        errorMessage =
            'There is a temporary issue with the server. Please try again in a few minutes.';
      } else {
        errorMessage = 'Failed to place order: ${e.toString()} ';
      }

      print('Showing error message: $errorMessage');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handlePickMeDelivery() async {
    try {
      // Close the form dialog first
      if (mounted) {
        Navigator.pop(context);
      }

      // Show loading indicator for PickMe
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text('Connecting to PickMe...'),
                ],
              ),
            );
          },
        );
      }

      // Prepare order details
      String orderDetails = "Golden Drip Coffee Order\n";
      for (var item in widget.cartProvider.items) {
        orderDetails += "${item.product.name} x${item.quantity}\n";
      }
      orderDetails +=
          "\nTotal: \$${widget.cartProvider.total.toStringAsFixed(2)}";
      orderDetails += "\nCustomer: ${_nameController.text}";
      orderDetails += "\nPhone: ${_phoneController.text}";

      // Launch PickMe with delivery details
      bool success = await PickMeService.launchPickMeDelivery(
        pickupLocation: "Golden Drip Coffee Shop",
        dropoffLocation: _addressController.text.isNotEmpty
            ? _addressController.text
            : "Customer Location",
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        deliveryNotes: orderDetails,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (success) {
        // Clear cart after successful redirection
        widget.cartProvider.clearCart();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirecting to PickMe for delivery...'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        // Call the success callback
        widget.onOrderSuccess();
      } else {
        // Show error if redirection failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not connect to PickMe. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Close any open dialogs
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to PickMe: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
