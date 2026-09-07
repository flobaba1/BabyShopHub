import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';

enum OrderStatus { pending, processing, shipped, outForDelivery, delivered }

class OrderModel {
  final String id;
  final String date;
  final double totalAmount;
  final String address;
  OrderStatus status;

  OrderModel({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.address,
    required this.status,
  });
}

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  final MySQLService _mysqlService = MySQLService();

  List<OrderModel> _orders = [];

  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ------------------------------------------------------------
  // LOAD ORDERS FROM DATABASE
  // ------------------------------------------------------------

  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final conn = await _mysqlService.connection;

      final result = await conn.execute('''
        SELECT
          o.id,
          o.status,
          o.totalAmount,
          o.shippingAddress,
          o.createdAt
        FROM Orders o
        ORDER BY o.createdAt DESC
        ''');

      final orders = result.rows.map((row) {
        final data = row.assoc();

        return OrderModel(
          id: data['id'] ?? '',
          date: _formatDate(data['createdAt']),
          totalAmount: double.tryParse(data['totalAmount'] ?? '0') ?? 0.0,
          address: data['shippingAddress'] ?? '',
          status: _statusFromDatabase(data['status']),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load orders.';
      });
    }
  }

  // ------------------------------------------------------------
  // CONVERT DATABASE STATUS TO ENUM
  // ------------------------------------------------------------

  OrderStatus _statusFromDatabase(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;

      case 'processing':
        return OrderStatus.processing;

      case 'shipped':
        return OrderStatus.shipped;

      case 'out_for_delivery':
      case 'out-for-delivery':
      case 'out for delivery':
        return OrderStatus.outForDelivery;

      case 'delivered':
        return OrderStatus.delivered;

      default:
        return OrderStatus.pending;
    }
  }

  // ------------------------------------------------------------
  // CONVERT ENUM TO DATABASE STATUS
  // ------------------------------------------------------------

  String _statusToDatabase(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';

      case OrderStatus.processing:
        return 'processing';

      case OrderStatus.shipped:
        return 'shipped';

      case OrderStatus.outForDelivery:
        return 'out_for_delivery';

      case OrderStatus.delivered:
        return 'delivered';
    }
  }

  // ------------------------------------------------------------
  // GET NEXT STATUS
  // ------------------------------------------------------------

  OrderStatus? _getNextStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return OrderStatus.processing;

      case OrderStatus.processing:
        return OrderStatus.shipped;

      case OrderStatus.shipped:
        return OrderStatus.outForDelivery;

      case OrderStatus.outForDelivery:
        return OrderStatus.delivered;

      case OrderStatus.delivered:
        return null;
    }
  }

  // ------------------------------------------------------------
  // UPDATE ORDER STATUS
  // ------------------------------------------------------------

  Future<void> _advanceOrderStatus(OrderModel order) async {
    final nextStatus = _getNextStatus(order.status);

    if (nextStatus == null) {
      return;
    }

    if (_isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _mysqlService.updateOrderStatus(
        orderId: order.id,
        status: _statusToDatabase(nextStatus),
      );

      if (!mounted) return;

      // Reload from DB so the database remains the source of truth.
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update order status.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // FORMAT DATE
  // ------------------------------------------------------------

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value);

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return value;
    }
  }

  // ------------------------------------------------------------
  // STATUS TEXT
  // ------------------------------------------------------------

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';

      case OrderStatus.processing:
        return 'Processing';

      case OrderStatus.shipped:
        return 'Shipped';

      case OrderStatus.outForDelivery:
        return 'Out for Delivery';

      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  // ------------------------------------------------------------
  // STATUS COLORS
  // ------------------------------------------------------------

  Color _statusBackground(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFE0F2FE);

      case OrderStatus.processing:
        return const Color(0xFFFEF3C7);

      case OrderStatus.shipped:
        return const Color(0xFFF3E8FF);

      case OrderStatus.outForDelivery:
        return const Color(0xFFE0F2FE);

      case OrderStatus.delivered:
        return const Color(0xFFDCFCE7);
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFF0284C7);

      case OrderStatus.processing:
        return const Color(0xFFD97706);

      case OrderStatus.shipped:
        return const Color(0xFF9333EA);

      case OrderStatus.outForDelivery:
        return const Color(0xFF0284C7);

      case OrderStatus.delivered:
        return const Color(0xFF16A34A);
    }
  }

  // ------------------------------------------------------------
  // BUTTON TEXT
  // ------------------------------------------------------------

  String _advanceButtonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Advance to: Processing';

      case OrderStatus.processing:
        return 'Advance to: Shipped';

      case OrderStatus.shipped:
        return 'Advance to: Out for Delivery';

      case OrderStatus.outForDelivery:
        return 'Advance to: Delivered';

      case OrderStatus.delivered:
        return '';
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Orders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E24),
          ),
        ),

        const SizedBox(height: 20),

        Expanded(child: _buildOrdersBody()),
      ],
    );
  }

  Widget _buildOrdersBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text('No orders found.', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];

          return _buildOrderCard(order);
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // ORDER CARD
  // ------------------------------------------------------------

  Widget _buildOrderCard(OrderModel order) {
    final statusText = _statusText(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // ORDER ID + STATUS
          // ------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E24),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusBackground(order.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------------
          // DATE + TOTAL
          // ------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.date,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E24),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // ADDRESS
          // ------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.address,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),

          // ------------------------------------------------------
          // ADVANCE BUTTON
          // ------------------------------------------------------
          if (order.status != OrderStatus.delivered) ...[
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating
                    ? null
                    : () => _advanceOrderStatus(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF7ED),
                  foregroundColor: const Color(0xFFEA580C),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFFEDD5)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  _advanceButtonText(order.status),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
