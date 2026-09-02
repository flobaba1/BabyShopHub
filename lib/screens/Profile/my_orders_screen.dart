import 'package:flutter/material.dart';
import 'track_order_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = [
      {
        'date': 'Aug 20, 2026',
        'orderId': 'ORD-2026-003',
        'status': 'Processing',
        'statusColor': const Color(0xFFE65100),
        'statusBg': const Color(0xFFFFF3E0),
        'itemsCount': 1,
        'price': '94.98',
        'icons': [Icons.card_giftcard],
      },
      {
        'date': 'Aug 18, 2026',
        'orderId': 'ORD-2026-002',
        'status': 'Shipped',
        'statusColor': const Color(0xFF7B1FA2),
        'statusBg': const Color(0xFFF3E5F5),
        'itemsCount': 3,
        'price': '77.97',
        'icons': [Icons.child_care, Icons.checkroom],
      },
      {
        'date': 'Aug 15, 2026',
        'orderId': 'ORD-2026-001',
        'status': 'Delivered',
        'statusColor': const Color(0xFF2E7D32),
        'statusBg': const Color(0xFFE8F5E9),
        'itemsCount': 3,
        'price': '62.97',
        'icons': [Icons.layers, Icons.card_giftcard],
      },
    ];

    return Scaffold(
      // Setting your custom background color precisely
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Header Layout Section
              Row(
                children: [
                  const Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('📦', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${orders.length} total orders',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // 3. Dynamic Orders Scroll List Area
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Custom Component Widget for cleanly structuring each individual Order Card
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row containing Order Metadata info and Status Pill Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['date'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['orderId'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E24),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: order['statusBg'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: order['statusColor'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order['status'],
                      style: TextStyle(
                        color: order['statusColor'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row containing Preview Thumbnails for ordered items
          Row(
            children: (order['icons'] as List<IconData>).map((icon) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.orange.shade300, size: 28),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Bottom Action row containing items recap statement and functional Track Order CTA Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order['itemsCount']} items · \$${order['price']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Integrated explicit navigation logic to Route forward to your TrackOrderScreen component
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrackOrderScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF3EC),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.orange,
                  size: 16,
                ),
                label: const Text(
                  'Track Order',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
