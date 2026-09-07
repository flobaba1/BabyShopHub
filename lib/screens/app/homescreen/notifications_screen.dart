import 'package:flutter/material.dart';

import '../../../core/mysql_service.dart';
import '../../../core/user_session.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final MySQLService _mysqlService = MySQLService();

  List<Map<String, dynamic>> _notifications = [];

  bool _isLoading = true;
  bool _isMarkingAll = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      await UserSession.loadUserSession();

      final userId = UserSession.loggedUser?.id;

      if (userId == null || userId.isEmpty) {
        throw Exception('No logged-in user found.');
      }

      final notifications = await _mysqlService.getUserNotifications(userId);

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load notifications: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load notifications.';
      });
    }
  }

  Future<void> _markAsRead(int index) async {
    final notification = _notifications[index];

    final notificationId = notification['id']?.toString();

    if (notificationId == null || notificationId.isEmpty) {
      return;
    }

    final isRead = _parseBool(notification['isRead']);

    if (isRead) {
      return;
    }

    try {
      await _mysqlService.markNotificationAsRead(notificationId);

      if (!mounted) return;

      setState(() {
        _notifications[index]['isRead'] = true;
      });
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isMarkingAll) return;

    final userId = UserSession.loggedUser?.id;

    if (userId == null || userId.isEmpty) {
      return;
    }

    final hasUnread = _notifications.any(
      (notification) => !_parseBool(notification['isRead']),
    );

    if (!hasUnread) return;

    setState(() {
      _isMarkingAll = true;
    });

    try {
      await _mysqlService.markAllNotificationsAsRead(userId);

      if (!mounted) return;

      setState(() {
        for (final notification in _notifications) {
          notification['isRead'] = true;
        }
      });
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to mark notifications as read.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAll = false;
        });
      }
    }
  }

  bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }

    return false;
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final dateString = value.toString();

    if (dateString.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();

      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      }

      if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      }

      if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      }

      if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      }

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
      return dateString;
    }
  }

  IconData _notificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'order_status':
        return Icons.local_shipping_outlined;

      case 'order':
        return Icons.shopping_bag_outlined;

      case 'delivery':
        return Icons.delivery_dining_outlined;

      case 'promotion':
        return Icons.local_offer_outlined;

      case 'support':
        return Icons.support_agent_rounded;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _notificationIconBackground(String? type) {
    switch (type?.toLowerCase()) {
      case 'order_status':
      case 'order':
        return const Color(0xFFFFE8DC);

      case 'delivery':
        return const Color(0xFFE0F5E5);

      case 'promotion':
        return const Color(0xFFFFF0D1);

      default:
        return const Color(0xFFF2F2F2);
    }
  }

  Color _notificationIconColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'order_status':
      case 'order':
        return const Color(0xFFFF6600);

      case 'delivery':
        return const Color(0xFF3FA65B);

      case 'promotion':
        return const Color(0xFFD89B31);

      default:
        return const Color(0xFF777777);
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = _parseBool(notification['isRead']);

    final title = notification['title']?.toString() ?? 'Notification';

    final message = notification['message']?.toString() ?? '';

    final type = notification['type']?.toString();

    final createdAt = _formatDate(notification['createdAt']);

    return GestureDetector(
      onTap: () => _markAsRead(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFFFF7F1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? const Color(0xFFEDE8E4) : const Color(0xFFFFDCC7),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _notificationIconBackground(type),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _notificationIcon(type),
                color: _notificationIconColor(type),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead
                                ? FontWeight.w700
                                : FontWeight.w800,
                            color: const Color(0xFF202938),
                          ),
                        ),
                      ),

                      if (!isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6600),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: Color(0xFF6E727A),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    createdAt,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA0AA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8DC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: Color(0xFFFF6600),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202938),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'We will notify you when there is an update\n'
              'about your orders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: Color(0xFF888E98),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: Color(0xFFFF6600),
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load notifications',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF202938),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: _loadNotifications,
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Color(0xFFFF6600),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications
        .where((notification) => !_parseBool(notification['isRead']))
        .length;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 206),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 240, 206),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Color(0xFF202938),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF202938),
          ),
        ),
        centerTitle: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _isMarkingAll ? null : _markAllAsRead,
              child: _isMarkingAll
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFF6600),
                      ),
                    )
                  : const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF6600),
                      ),
                    ),
            ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6600)),
              )
            : _errorMessage != null
            ? _buildErrorState()
            : _notifications.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                color: const Color(0xFFFF6600),
                onRefresh: _loadNotifications,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(17, 8, 17, 25),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index], index);
                  },
                ),
              ),
      ),
    );
  }
}
