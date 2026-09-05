import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: Colors.white,

      // Main screen
      body: navigationShell,

      // Bottom navigation
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFECECEC), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // ==========================================================
              // HOME - BRANCH 0
              // ==========================================================
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () {
                    navigationShell.goBranch(0, initialLocation: true);
                  },
                ),
              ),

              // ==========================================================
              // CATEGORIES - BRANCH 1
              // ==========================================================
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'Categories',
                  isSelected: currentIndex == 1,
                  onTap: () {
                    navigationShell.goBranch(1, initialLocation: true);
                  },
                ),
              ),

              // ==========================================================
              // CART - BRANCH 2
              // ==========================================================
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'Cart',
                  isSelected: currentIndex == 2,
                  onTap: () {
                    navigationShell.goBranch(2, initialLocation: true);
                  },
                ),
              ),

              // ==========================================================
              // ORDERS - BRANCH 3
              // ==========================================================
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: 'Orders',
                  isSelected: currentIndex == 3,
                  onTap: () {
                    navigationShell.goBranch(3, initialLocation: true);
                  },
                ),
              ),

              // ==========================================================
              // PROFILE - BRANCH 4
              // ==========================================================
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () {
                    navigationShell.goBranch(4, initialLocation: true);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// BOTTOM NAVIGATION ITEM
// ==========================================================

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              isSelected ? activeIcon : icon,
              size: 23,
              color: isSelected
                  ? const Color(0xFFFF6600)
                  : const Color(0xFF9AA2B1),
            ),

            const SizedBox(height: 3),

            // Label
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFF6600)
                    : const Color(0xFF9AA2B1),
              ),
            ),

            const SizedBox(height: 2),

            // Active indicator
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6600),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
