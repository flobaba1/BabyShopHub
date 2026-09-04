import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/utilities/models/dashboard_models.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final MySQLService _dbService = MySQLService();

  List<DashboardMetric> _metrics = [];
  List<RecentOrder> _recentOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final metrics = await _dbService.fetchDashboardMetrics();
      final orders = await _dbService.fetchRecentOrders();

      if (mounted) {
        setState(() {
          _metrics = metrics;
          _recentOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF5722)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFFFF5722),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Stat Cards Grid (2x2)
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _metrics.length,
              itemBuilder: (context, index) {
                final metric = _metrics[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: metric.iconBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          metric.icon,
                          color: metric.iconColor,
                          size: 20,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            metric.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 2. Recent Orders Card Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _recentOrders.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'No recent orders found.',
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentOrders.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 20,
                            color: Color(0xFFF3F4F6),
                          ),
                          itemBuilder: (context, index) {
                            final order = _recentOrders[index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.id,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      order.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: order.statusBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: order.statusText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      order.price,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
