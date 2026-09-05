import 'package:flutter/material.dart';


enum OrderStatus { processing, shipped, outForDelivery, delivered }


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
 
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-2026-003',
      date: 'Aug 20, 2026',
      totalAmount: 94.98,
      address: '123 Maple Street, Springfield, IL 62701',
      status: OrderStatus.processing,
    ),
    OrderModel(
      id: 'ORD-2026-002',
      date: 'Aug 18, 2026',
      totalAmount: 77.97,
      address: '123 Maple Street, Springfield, IL 62701',
      status: OrderStatus.shipped,
    ),
    OrderModel(
      id: 'ORD-2026-001',
      date: 'Aug 15, 2026',
      totalAmount: 62.97,
      address: '123 Maple Street, Springfield, IL 62701',
      status: OrderStatus.delivered,
    ),
  ];

  // Helper method to advance status
  void _advanceOrderStatus(OrderModel order) {
    setState(() {
      if (order.status == OrderStatus.processing) {
        order.status = OrderStatus.shipped;
      } else if (order.status == OrderStatus.shipped) {
        order.status = OrderStatus.outForDelivery;
      } else if (order.status == OrderStatus.outForDelivery) {
        order.status = OrderStatus.delivered;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Manage Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              return _buildOrderCard(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 4),

          // Date & Total Price
          Text(
            '${order.date} · \$${order.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),

          // Address Row
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (order.status != OrderStatus.delivered) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _advanceOrderStatus(order),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF7ED), 
                  side: const BorderSide(color: Color(0xFFFFEDD5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getButtonText(order.status),
                      style: const TextStyle(
                        color: Color(0xFFEA580C), // Orange primary
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFEA580C)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Dynamic Status Badge Helper
  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case OrderStatus.processing:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        label = 'Processing';
        break;
      case OrderStatus.shipped:
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF9333EA);
        label = 'Shipped';
        break;
      case OrderStatus.outForDelivery:
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0284C7);
        label = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'Delivered';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper text for the button depending on current state
  String _getButtonText(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'Advance to: Shipped';
      case OrderStatus.shipped:
        return 'Advance to: Out for Delivery';
      case OrderStatus.outForDelivery:
        return 'Advance to: Delivered';
      default:
        return '';
    }
  }
}