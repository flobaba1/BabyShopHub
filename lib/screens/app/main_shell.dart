import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final int index = navigationShell.currentIndex;

    return Scaffold(
      // Dynamic Top AppBar based on active branch
      appBar: _buildAppBar(context, index),

      body: navigationShell,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (newIndex) => navigationShell.goBranch(
          newIndex,
          initialLocation: newIndex == index,
        ),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Dashboard Custom Greeting Header
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text('N', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Good afternoon,', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('New 👋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
          ],
        );

      case 1:
        // Categories Screen Header
        return AppBar(
          title: const Text('All Categories'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
        );

      case 2:
        // Cart Screen Header
        return AppBar(
          title: const Text('My Shopping Cart'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        );

      case 3:
        // Profile Screen Header
        return AppBar(
          title: const Text('Account & Settings'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          actions: [
            IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          ],
        );

      default:
        return AppBar(title: const Text('Baby Shop'));
    }
  }
}