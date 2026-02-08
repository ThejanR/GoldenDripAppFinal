import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../providers/profile_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orders = await OrderService.getUserOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrderHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const EmptyOrderHistoryView()
                  : RefreshIndicator(
                      onRefresh: _loadOrderHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(_orders[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Order date
              Text(
                'Placed on ${_formatDate(order.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),

              // Order items preview
              _buildItemsPreview(order.items),
              const SizedBox(height: 12),

              // Order total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsPreview(List items) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Show first 2 items with count
    final displayItems = items.take(2).toList();
    final remainingCount = items.length > 2 ? items.length - 2 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('• ', style: Theme.of(context).textTheme.bodySmall),
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.productName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${(item.productPrice * item.quantity).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )),
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+$remainingCount more items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
      ],
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Details',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order info
                        _buildDetailSection('Order Information', [
                          _DetailRow('Order ID', '#${order.id}'),
                          _DetailRow('Status', order.status.toUpperCase(),
                              color: _getStatusColor(order.status)),
                          _DetailRow('Date', _formatDateTime(order.createdAt)),
                          _DetailRow('Payment Method', order.paymentMethod),
                        ]),

                        const SizedBox(height: 16),

                        // Items
                        _buildDetailSection('Items',
                            order.items.map((item) => _ItemRow(item)).toList()),

                        const SizedBox(height: 16),

                        // Summary
                        _buildDetailSection('Order Summary', [
                          _DetailRow('Subtotal',
                              '\$${order.subtotal.toStringAsFixed(2)}'),
                          _DetailRow(
                              'Tax', '\$${order.tax.toStringAsFixed(2)}'),
                          if (order.deliveryFee > 0)
                            _DetailRow('Delivery Fee',
                                '\$${order.deliveryFee.toStringAsFixed(2)}'),
                          const Divider(),
                          _DetailRow(
                              'Total', '\$${order.total.toStringAsFixed(2)}',
                              isBold: true),
                        ]),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _DetailRow(this.label, this.value, {this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: isBold ? FontWeight.bold : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final dynamic item;

  const _ItemRow(this.item);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_cafe,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (item.notes != null && item.notes.isNotEmpty)
                  Text(
                    item.notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity}x',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '\$${(item.productPrice * item.quantity).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyOrderHistoryView extends StatelessWidget {
  const EmptyOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here once you place your first order.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate to menu
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.local_cafe),
              label: const Text('Start Ordering'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper methods
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'processing':
      return Colors.orange;
    case 'cancelled':
      return Colors.red;
    case 'delivered':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
