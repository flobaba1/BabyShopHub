import 'package:flutter/material.dart';

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

  
  factory DashboardMetric.fromMap(Map<String, dynamic> map) {
    return DashboardMetric(
      label: map['label'] ?? '',
      value: map['value']?.toString() ?? '0',
      subtext: map['subtext'] ?? '',
      icon: _getIconData(map['icon_name']),
      iconColor: Color(map['icon_color'] ?? 0xFFFF5722),
      iconBg: Color(map['icon_bg'] ?? 0xFFFBE9E7),
    );
  }

  static IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'attach_money':
        return Icons.attach_money;
      case 'people':
        return Icons.people;
      case 'inventory':
        return Icons.inventory_2;
      default:
        return Icons.analytics;
    }
  }
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

 
  factory RecentOrder.fromMap(Map<String, dynamic> map) {
    final status = map['status']?.toString().toUpperCase() ?? 'PENDING';

    return RecentOrder(
      id: '#${map['order_id'] ?? map['id']}',
      date: map['created_at']?.toString().split('T').first ?? '',
      status: status,
      price: '\$${map['total_amount'] ?? map['price'] ?? '0.00'}',
      statusBg: _getStatusBg(status),
      statusText: _getStatusText(status),
    );
  }

  static Color _getStatusBg(String status) {
    switch (status) {
      case 'DELIVERED':
      case 'COMPLETED':
        return const Color(0xFFDEF7EC);
      case 'PENDING':
      case 'PROCESSING':
        return const Color(0xFFFEF3C7);
      case 'CANCELLED':
        return const Color(0xFFFDE8E8);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  static Color _getStatusText(String status) {
    switch (status) {
      case 'DELIVERED':
      case 'COMPLETED':
        return const Color(0xFF03543F);
      case 'PENDING':
      case 'PROCESSING':
        return const Color(0xFF92400E);
      case 'CANCELLED':
        return const Color(0xFF9B1C1C);
      default:
        return const Color(0xFF374151);
    }
  }
}
