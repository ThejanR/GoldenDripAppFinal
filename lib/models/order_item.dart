class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final String? notes;
  final List<String> selectedOptions;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    this.notes,
    required this.selectedOptions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int? ?? 0,
      orderId: json['order_id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product']?['name'] as String? ??
          json['product_name'] as String? ??
          'Unknown Product',
      productPrice: (json['product_price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] as String?,
      selectedOptions: json['selected_options'] is List
          ? List<String>.from(json['selected_options'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'notes': notes,
      'selected_options': selectedOptions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get totalPrice => productPrice * quantity;
  String get totalPriceFormatted => '\$${totalPrice.toStringAsFixed(2)}';
}
