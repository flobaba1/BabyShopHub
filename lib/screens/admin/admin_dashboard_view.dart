import 'package:flutter/material.dart';

// 1. DATA MODELS (Prepared for API/Database Integration)
class DashboardMetric {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final String subtext;

  const DashboardMetric({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.subtext,
  });
}

class RecentOrder {
  final String id;
  final String date;
  final String status;
  final String price;
  final Color statusBg;
  final Color statusText;

  const RecentOrder({
    required this.id,
    required this.date,
    required this.status,
    required this.price,
    required this.statusBg,
    required this.statusText,
  });
}

// 2. DASHBOARD VIEW WIDGET
class AdminDashboardView extends StatelessWidget {
 
  final List<DashboardMetric> metrics;
  final List<RecentOrder> recentOrders;

  const AdminDashboardView({
    super.key,
    this.metrics = _defaultMetrics,
    this.recentOrders = _defaultOrders,
  });

 
  static const List<DashboardMetric> _defaultMetrics = [
    DashboardMetric(
      icon: Icons.trending_up_rounded,
      iconColor: Color(0xFF16A34A),
      iconBg: Color(0xFFDCFCE7),
      value: '\$236',
      label: 'Revenue',
      subtext: '+12% this week',
    ),
    DashboardMetric(
      icon: Icons.shopping_bag_outlined,
      iconColor: Color(0xFF2563EB),
      iconBg: Color(0xFFDBEAFE),
      value: '3',
      label: 'Orders',
      subtext: '0 new',
    ),
    DashboardMetric(
      icon: Icons.inventory_2_outlined,
      iconColor: Color(0xFF9333EA),
      iconBg: Color(0xFFF3E8FF),
      value: '12',
      label: 'Products',
      subtext: 'Active listings',
    ),
    DashboardMetric(
      icon: Icons.people_outline_rounded,
      iconColor: Color(0xFFEA580C),
      iconBg: Color(0xFFFFEDD5),
      value: '1,284',
      label: 'Users',
      subtext: '+43 this week',
    ),
  ];

  static const List<RecentOrder> _defaultOrders = [
    RecentOrder(
      id: 'ORD-2026-003',
      date: 'Aug 20, 2026',
      status: 'Processing',
      price: '\$95',
      statusBg: Color(0xFFFEF3C7),
      statusText: Color(0xFFD97706),
    ),
    RecentOrder(
      id: 'ORD-2026-002',
      date: 'Aug 18, 2026',
      status: 'Shipped',
      price: '\$78',
      statusBg: Color(0xFFF3E8FF),
      statusText: Color(0xFF9333EA),
    ),
    RecentOrder(
      id: 'ORD-2026-001',
      date: 'Aug 15, 2026',
      status: 'Delivered',
      price: '\$63',
      statusBg: Color(0xFFDCFCE7),
      statusText: Color(0xFF16A34A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Dynamic Grid Metrics
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              return StatCard(metric: metrics[index]);
            },
          ),
          const SizedBox(height: 16),

          // Dynamic Recent Orders Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentOrders.length,
                  separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  itemBuilder: (context, index) {
                    return OrderItemRow(order: recentOrders[index]);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final DashboardMetric metric;

  const StatCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: metric.iconBg, shape: BoxShape.circle),
            child: Icon(metric.icon, color: metric.iconColor, size: 20),
          ),
          const Spacer(),
          Text(metric.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          Text(metric.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          Text(metric.subtext, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class OrderItemRow extends StatelessWidget {
  final RecentOrder order;

  const OrderItemRow({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(order.date, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: order.statusBg, borderRadius: BorderRadius.circular(12)),
              child: Text(order.status, style: TextStyle(color: order.statusText, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Text(order.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
          ],
        )
      ],
    );
  }
}