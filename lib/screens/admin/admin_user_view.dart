import 'package:flutter/material.dart';


class UserModel {
  final String name;
  final String email;
  final int orderCount;
  final String joinedDate;
  bool isActive;

  UserModel({
    required this.name,
    required this.email,
    required this.orderCount,
    required this.joinedDate,
    required this.isActive,
  });
}

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  
  final List<UserModel> _users = [
    UserModel(
      name: 'Emma Johnson',
      email: 'emma@example.com',
      orderCount: 3,
      joinedDate: 'Jan 2026',
      isActive: true,
    ),
    UserModel(
      name: 'Sarah Mitchell',
      email: 'sarah@example.com',
      orderCount: 7,
      joinedDate: 'Mar 2026',
      isActive: true,
    ),
    UserModel(
      name: 'David Kim',
      email: 'david@example.com',
      orderCount: 2,
      joinedDate: 'Jun 2026',
      isActive: true,
    ),
    UserModel(
      name: 'Priya Sharma',
      email: 'priya@example.com',
      orderCount: 5,
      joinedDate: 'Feb 2026',
      isActive: true,
    ),
    UserModel(
      name: 'James Roberts',
      email: 'james@example.com',
      orderCount: 1,
      joinedDate: 'Aug 2026',
      isActive: false,
    ),
  ];

  void _toggleUserStatus(UserModel user) {
    setState(() {
      user.isActive = !user.isActive;
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
            'User Management',
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
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _buildUserCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    // Extract first character of name for circle avatar
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar Initial Circle
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFEDD5), 
            child: Text(
              initial,
              style: const TextStyle(
                color: Color(0xFFEA580C), 
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Main Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.orderCount} orders · Joined ${user.joinedDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

        
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Active / Inactive Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? const Color(0xFFDCFCE7) // Green background
                      : const Color(0xFFF3F4F6), // Grey background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.isActive
                        ? const Color(0xFF16A34A) // Green text
                        : const Color(0xFF6B7280), // Grey text
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Edit / Toggle Button
              InkWell(
                onTap: () => _toggleUserStatus(user),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFFEA580C),
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