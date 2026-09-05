import 'package:flutter/material.dart';

class TrackOrderScreen extends StatelessWidget {
  final String orderId;
  final String status;
  const TrackOrderScreen({super.key, required this.orderId, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Setting your custom background color setup exactly
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order ID Card Component
              _buildOrderIDCard(),
              const SizedBox(height: 20),

              // 2. Tracking Timeline Card Component
              _buildTimelineCard(),
              const SizedBox(height: 20),

              // 3. Items Recaps Card Component
              _buildItemsRecapCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Card block displaying Order ID, processing status tag, and address info
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
                children: const [
                  Text(
                    'Order ID',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ORD-2026-003',
                    style: TextStyle(
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
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Processing',
                  style: TextStyle(
                    color: Color(0xFFE65100),
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
            children: const [
              Icon(Icons.location_on_outlined, color: Colors.orange, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '123 Maple Street, Springfield, IL 62701',
                  style: TextStyle(
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

  // Complete Custom Tracking Timeline Step vertical sequence
  Widget _buildTimelineCard() {
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
          const SizedBox(height: 24),

          _buildTimelineRow(
            title: 'Order Placed',
            subtitle: 'We received your order',
            time: 'Aug 15, 2026 - 10:00 AM',
            icon: Icons.check,
            iconColor: Colors.white,
            badgeBg: Colors.green,
            lineColor: Colors.green,
            isActive: true,
          ),
          _buildTimelineRow(
            title: 'Processing',
            subtitle: 'Items being packed',
            time: 'Aug 16, 2026 - 12:00 AM',
            icon: Icons.card_giftcard,
            iconColor: Colors.white,
            badgeBg: Colors.orange,
            lineColor: Colors.grey.shade200,
            isActive: true,
          ),
          _buildTimelineRow(
            title: 'Shipped',
            subtitle: 'On its way to you',
            time: '',
            icon: Icons.local_shipping_outlined,
            iconColor: Colors.grey.shade300,
            badgeBg: Colors.grey.shade100,
            lineColor: Colors.grey.shade200,
            isActive: false,
          ),
          _buildTimelineRow(
            title: 'Out for Delivery',
            subtitle: 'With your delivery partner',
            time: '',
            icon: Icons.delivery_dining_outlined,
            iconColor: Colors.grey.shade300,
            badgeBg: Colors.grey.shade100,
            lineColor: Colors.grey.shade200,
            isActive: false,
          ),
          _buildTimelineRow(
            title: 'Delivered',
            subtitle: 'Enjoy your purchase!',
            time: '',
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.grey.shade300,
            badgeBg: Colors.grey.shade100,
            lineColor: Colors.transparent, // Terminates line continuity here
            isActive: false,
          ),
        ],
      ),
    );
  }

  // Indidivual Row tracking list entry
  Widget _buildTimelineRow({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color badgeBg,
    required Color lineColor,
    required bool isActive,
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
                child: Icon(icon, color: iconColor, size: 18),
              ),
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

  // Items billing summary layout details block card
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

          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                // Purely local assets setup version (Change path string text as needed)
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/your_diaper_bag.png', // <-- REPLACE WITH YOUR ASSET NAME
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback UI block backstop option if path naming configuration has asset mismatch typos
                      return const Icon(
                        Icons.card_giftcard,
                        color: Colors.orange,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Skip Hop Forma Diaper Bag',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E1E24),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Skip Hop · Qty 1',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Text(
                '\$89.99',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E1E24),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Total Paid',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E24),
                ),
              ),
              Text(
                '\$94.98',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
