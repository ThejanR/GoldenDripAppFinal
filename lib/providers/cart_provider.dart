import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.08; // 8% tax

  double get fees => 1.50; // Fixed service fee

  double get total => subtotal + tax + fees;

  bool get isEmpty => _items.isEmpty;

  int getProductQuantity(Product product) {
    final cartItem = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return cartItem.quantity;
  }

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // Product exists, increase quantity
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      // Add new product
      _items.add(CartItem(product: product, quantity: 1));
    }

    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      if (_items[index].quantity > 1) {
        // Decrease quantity
        _items[index] = _items[index].copyWith(
          quantity: _items[index].quantity - 1,
        );
      } else {
        // Remove item completely
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  void updateQuantity(Product product, int newQuantity) {
    if (newQuantity <= 0) {
      removeAllOfProduct(product);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void removeAllOfProduct(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
