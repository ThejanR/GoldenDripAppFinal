import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/pickme_service.dart';
import 'dart:async';
import 'order_success_screen.dart';

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
      print('OrderService.createOrder completed successfully');
      
      // Clear cart
      print('Clearing cart');
      widget.cartProvider.clearCart();
      
      // Close the checkout dialog
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Navigate to success screen using a small delay to ensure dialog is closed
      print('Navigating to success screen');
      // Use the parent context or a new Future to navigate after dialog closes
      if (widget.onOrderSuccess != null) {
         widget.onOrderSuccess();
      }

      // We need to access the parent navigator, but since we just popped, 'context' might be invalid for pushing if it was the dialog's context.
      // However, usually Navigator.push can works if we have a valid context. 
      // Better approach: The parent widget (CartScreen) should handle navigation on success, OR we push the route.
      // Let's try pushing the route effectively.
      
      // NOTE: We've popped the dialog, so we are back to CartScreen or whatever opened it.
      // We should use the context of the widget that opened the dialog? No, we can't access it easily here.
      // But 'context' here is the CheckoutForm (which was in the dialog).
      
      // Let's rely on onOrderSuccess for parent updates, but we need to push the Success Screen.
      // Since we poised the dialog, we need a context that is still in the tree.
      
      // Actually, simply pushing the route BEFORE popping the dialog is weird (success screen over dialog?).
      // Pushing AFTER popping is standard.
      
      // Let's retry the pattern: 
      // 1. await createOrder
      // 2. Navigator.pop(context) (closes dialog)
      // 3. Navigator.push(context, SuccessScreen) (might fail if context is dead)
      
      // FIX: pass the NavigatorState or use a GlobalKey, OR...
      // Just push the SuccessScreen replacing the Dialog? No, replace means replace dialog with screen.
      
      // Let's try:
      // Navigator.of(context).pushReplacement(...)
      
      // The issue is likely that we popped EARLY at line 205 in the original code.
      // I am removing that early pop in this edit.
      
      if (mounted) {
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OrderSuccessScreen(),
          ),
        );
      }
      
      print('Order process completed successfully');
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
