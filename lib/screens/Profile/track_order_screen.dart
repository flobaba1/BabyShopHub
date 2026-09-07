import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderId;
  final String status;

  const TrackOrderScreen({
    super.key,
    required this.orderId,
    required this.status,
  });

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final MySQLService _mysqlService = MySQLService();

  String _status = 'pending';
  bool _isLoading = true;

  String _shippingAddress = '';

  DateTime? _createdAt;
  DateTime? _updatedAt;

  List<Map<String, dynamic>> _orderItems = [];

  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();

    _status = widget.status.toLowerCase();

    _loadOrder();
  }

  // ============================================================
  // LOAD ORDER + ORDER ITEMS
  // ============================================================

  Future<void> _loadOrder() async {
    try {
      final conn = await _mysqlService.connection;

      // Get order information
      final result = await conn.execute(
        '''
        SELECT
          id,
          status,
          shippingAddress,
          totalAmount,
          createdAt,
          updatedAt
        FROM Orders
        WHERE id = :orderId
        LIMIT 1
        ''',
        {'orderId': widget.orderId},
      );

      // Get products belonging to this order
      final items = await _mysqlService.getOrderItems(widget.orderId);

      if (result.rows.isNotEmpty) {
        final data = result.rows.first.assoc();

        if (!mounted) return;

        setState(() {
          _status = (data['status'] ?? 'pending').toString().toLowerCase();

          _shippingAddress = data['shippingAddress']?.toString() ?? '';

          _createdAt = data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt'].toString())
              : null;

          _updatedAt = data['updatedAt'] != null
              ? DateTime.tryParse(data['updatedAt'].toString())
              : null;

          _orderItems = items;

          // Use the actual total from Orders
          _totalPaid =
              double.tryParse(data['totalAmount']?.toString() ?? '0') ?? 0.0;

          _isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          _orderItems = items;
          _totalPaid = 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('LOAD ORDER ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  int _statusIndex() {
    switch (_status.toLowerCase()) {
      case 'pending':
        return 0;

      case 'processing':
        return 1;

      case 'shipped':
        return 2;

      case 'out_for_delivery':
      case 'out-for-delivery':
      case 'out for delivery':
        return 3;

      case 'delivered':
        return 4;

      default:
        return 0;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Processing';

      case 'shipped':
        return 'Shipped';

      case 'out_for_delivery':
      case 'out-for-delivery':
      case 'out for delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'pending':
      default:
        return 'Pending';
    }
  }

  Color _statusColor() {
    switch (_status.toLowerCase()) {
      case 'processing':
        return const Color(0xFFE65100);

      case 'shipped':
        return const Color(0xFF7B1FA2);

      case 'out_for_delivery':
      case 'out-for-delivery':
      case 'out for delivery':
        return const Color(0xFF0284C7);

      case 'delivered':
        return const Color(0xFF2E7D32);

      case 'pending':
      default:
        return const Color(0xFF1565C0);
    }
  }

  Color _statusBackground() {
    switch (_status.toLowerCase()) {
      case 'processing':
        return const Color(0xFFFFF3E0);

      case 'shipped':
        return const Color(0xFFF3E5F5);

      case 'out_for_delivery':
      case 'out-for-delivery':
      case 'out for delivery':
        return const Color(0xFFE0F2FE);

      case 'delivered':
        return const Color(0xFFE8F5E9);

      case 'pending':
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: Padding(
          padding: const EdgeInsets.all(8.0),

          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
                size: 20,
              ),

              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        title: const Text(
          'Track Order',
          style: TextStyle(
            color: Color(0xFF1E1E24),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrder,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      _buildOrderIDCard(),

                      const SizedBox(height: 20),

                      _buildTimelineCard(),

                      const SizedBox(height: 20),

                      _buildItemsRecapCard(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ============================================================
  // ORDER ID CARD
  // ============================================================

  Widget _buildOrderIDCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Order ID',

                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.orderId,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E24),
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: _statusBackground(),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Text(
                  _formatStatus(_status),

                  style: TextStyle(
                    color: _statusColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),

            child: Divider(height: 1),
          ),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.orange,
                size: 20,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  _shippingAddress.isEmpty
                      ? 'Shipping address unavailable'
                      : _shippingAddress,

                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildTimelineCard() {
    final currentIndex = _statusIndex();

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Tracking Timeline',

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E24),
            ),
          ),

          const SizedBox(height: 20),

          // ORDER PLACED
          _buildTimelineRow(
            title: 'Order Placed',
            subtitle: 'We received your order',

            time: _createdAt != null
                ? '${_createdAt!.month}/${_createdAt!.day}/${_createdAt!.year}'
                : '',

            icon: Icons.check,

            isCompleted: currentIndex > 0,

            iconColor: currentIndex == 0
                ? const Color(0xFF2E7D32)
                : Colors.white,

            badgeBg: currentIndex > 0
                ? const Color(0xFF00C853)
                : const Color(0xFFE8F5E9),

            lineColor: currentIndex >= 1
                ? const Color(0xFF00C853)
                : Colors.grey.shade200,

            isActive: currentIndex >= 0,

            showLine: true,
          ),

          // PROCESSING
          _buildTimelineRow(
            title: 'Processing',
            subtitle: 'Items being packed',

            time: _updatedAt != null && currentIndex >= 1
                ? '${_updatedAt!.month}/${_updatedAt!.day}/${_updatedAt!.year}'
                : '',

            icon: currentIndex > 1 ? Icons.check : Icons.inventory_2_outlined,

            isCompleted: currentIndex > 1,

            iconColor: currentIndex > 1
                ? Colors.white
                : (currentIndex == 1 ? Colors.white : Colors.grey.shade400),

            badgeBg: currentIndex > 1
                ? const Color(0xFF00C853)
                : (currentIndex == 1
                      ? const Color(0xFFE65100)
                      : Colors.grey.shade100),

            lineColor: currentIndex >= 2
                ? const Color(0xFF00C853)
                : Colors.grey.shade200,

            isActive: currentIndex >= 1,

            showLine: true,
          ),

          // SHIPPED
          _buildTimelineRow(
            title: 'Shipped',
            subtitle: 'On its way to you',

            time: '',

            icon: currentIndex > 2
                ? Icons.check
                : Icons.local_shipping_outlined,

            isCompleted: currentIndex > 2,

            iconColor: currentIndex > 2
                ? Colors.white
                : (currentIndex == 2
                      ? const Color(0xFF7B1FA2)
                      : Colors.grey.shade400),

            badgeBg: currentIndex > 2
                ? const Color(0xFF00C853)
                : (currentIndex == 2
                      ? const Color(0xFFF3E5F5)
                      : Colors.grey.shade100),

            lineColor: currentIndex >= 3
                ? const Color(0xFF00C853)
                : Colors.grey.shade200,

            isActive: currentIndex >= 2,

            showLine: true,
          ),

          // OUT FOR DELIVERY
          _buildTimelineRow(
            title: 'Out for Delivery',
            subtitle: 'With your delivery partner',

            time: '',

            icon: currentIndex > 3
                ? Icons.check
                : Icons.delivery_dining_outlined,

            isCompleted: currentIndex > 3,

            iconColor: currentIndex > 3
                ? Colors.white
                : (currentIndex == 3
                      ? const Color(0xFF0284C7)
                      : Colors.grey.shade400),

            badgeBg: currentIndex > 3
                ? const Color(0xFF00C853)
                : (currentIndex == 3
                      ? const Color(0xFFE0F2FE)
                      : Colors.grey.shade100),

            lineColor: currentIndex >= 4
                ? const Color(0xFF00C853)
                : Colors.grey.shade200,

            isActive: currentIndex >= 3,

            showLine: true,
          ),

          // DELIVERED
          _buildTimelineRow(
            title: 'Delivered',
            subtitle: 'Enjoy your purchase!',

            time: '',

            icon: Icons.check_circle_outline,

            isCompleted: false,

            iconColor: currentIndex >= 4
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade400,

            badgeBg: currentIndex >= 4
                ? const Color(0xFFE8F5E9)
                : Colors.grey.shade100,

            lineColor: Colors.transparent,

            isActive: currentIndex >= 4,

            showLine: false,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIMELINE ROW
  // ============================================================

  Widget _buildTimelineRow({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color badgeBg,
    required Color lineColor,
    required bool isActive,
    required bool showLine,
    required bool isCompleted,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,

                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  isCompleted ? Icons.check : icon,

                  color: iconColor,
                  size: 18,
                ),
              ),

              if (showLine)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,

                      color: isActive
                          ? const Color(0xFF1E1E24)
                          : Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,

                    style: TextStyle(
                      fontSize: 13,

                      color: isActive ? Colors.black54 : Colors.grey.shade400,
                    ),
                  ),

                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      time,

                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ITEMS IN THIS ORDER
  // ============================================================

  Widget _buildItemsRecapCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Items in this Order',

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E24),
            ),
          ),

          const SizedBox(height: 16),

          if (_orderItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),

              child: Center(
                child: Text(
                  'No items found for this order.',

                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ..._orderItems.map((item) => _buildOrderItem(item)),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),

            child: Divider(height: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Total Paid',

                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              Text(
                '₦${_totalPaid.toStringAsFixed(2)}',

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SINGLE ORDER ITEM
  // ============================================================

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Unknown Product';

    final brand = item['brand']?.toString() ?? '';

    final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

    final totalPrice =
        double.tryParse(item['totalPrice']?.toString() ?? '0') ?? 0.0;

    final imageData = item['imageBytes'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          _buildProductImage(imageData),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  name,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E24),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  brand.isEmpty ? 'Qty $quantity' : '$brand · Qty $quantity',

                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '₦${totalPrice.toStringAsFixed(2)}',

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E24),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE FROM MEDIUMBLOB
  // ============================================================

  Widget _buildProductImage(dynamic imageData) {
    if (imageData == null) {
      return _emptyProductImage();
    }

    try {
      Uint8List bytes;

      if (imageData is Uint8List) {
        bytes = imageData;
      } else if (imageData is List<int>) {
        bytes = Uint8List.fromList(imageData);
      } else {
        return _emptyProductImage();
      }

      if (bytes.isEmpty) {
        return _emptyProductImage();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(14),

        child: Image.memory(
          bytes,

          width: 70,
          height: 70,

          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {
            return _emptyProductImage();
          },
        ),
      );
    } catch (e) {
      debugPrint('PRODUCT IMAGE ERROR: $e');

      return _emptyProductImage();
    }
  }

  // ============================================================
  // EMPTY IMAGE
  // ============================================================

  Widget _emptyProductImage() {
    return Container(
      width: 70,
      height: 70,

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 30),
    );
  }
}
