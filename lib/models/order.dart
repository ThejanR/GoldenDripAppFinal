import 'order_item.dart';

class Order {
  final int id;
  final int userId;
  final String status;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String? deliveryInstructions;
  final String paymentMethod;
  final String? paymentStatus;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    this.deliveryInstructions,
    required this.paymentMethod,
    this.paymentStatus,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryInstructions: json['delivery_instructions'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentStatus: json['payment_status'] as String?,
      items: json['items'] is List
          ? List<OrderItem>.from(json['items']
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>)))
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
      'user_id': userId,
      'status': status,
      'subtotal': subtotal,
      'tax': tax,
      'delivery_fee': deliveryFee,
      'total': total,
      'delivery_address': deliveryAddress,
      'delivery_instructions': deliveryInstructions,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready for Pickup';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'confirmed':
        return 'blue';
      case 'preparing':
        return 'purple';
      case 'ready':
        return 'green';
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'gray';
    }
  }

  String get totalFormatted => '\$${total.toStringAsFixed(2)}';
  String get subtotalFormatted => '\$${subtotal.toStringAsFixed(2)}';
}
