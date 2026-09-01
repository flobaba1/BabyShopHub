import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_shop_hub/screens/auth/login.dart';
import 'package:baby_shop_hub/screens/auth/signup.dart';
import 'package:baby_shop_hub/screens/app/main_shell.dart';
import 'package:baby_shop_hub/screens/app/homescreen/homescreen.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding.dart';
import 'package:baby_shop_hub/screens/app/products/all_products.dart';
import 'package:baby_shop_hub/screens/app/products/filtered_products.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialRoute) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,

    initialLocation: '/home',

    routes: [
      // ==========================================================
      // AUTH / ONBOARDING ROUTES
      // ==========================================================
      GoRoute(
        path: '/products',
        builder: (context, state) {
          return const AllProductsScreen();
        },
      ),

      GoRoute(
        path: '/products/filter',
        builder: (context, state) {
          return const FilteredProductsScreen();
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ==========================================================
      // MAIN APP SHELL
      // ==========================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },

        branches: [
          // ======================================================
          // 0 - HOME
          // ======================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return const HomeScreen();
                },
              ),
            ],
          ),

          // ======================================================
          // 1 - CATEGORIES
          // ======================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) {
                  return const CategoriesPlaceholder();
                },
              ),
            ],
          ),

          // ======================================================
          // 2 - CART
          // ======================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) {
                  return const CartPlaceholder();
                },
              ),
            ],
          ),

          // ======================================================
          // 3 - ORDERS
          // ======================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) {
                  return const OrdersPlaceholder();
                },
              ),
            ],
          ),

          // ======================================================
          // 4 - PROFILE
          // ======================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfilePlaceholder();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ================================================================
// TEMPORARY PLACEHOLDER SCREENS
// ================================================================
// We can replace these with the actual UI screens later.
// ================================================================

class CategoriesPlaceholder extends StatelessWidget {
  const CategoriesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Categories',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CartPlaceholder extends StatelessWidget {
  const CartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Cart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class OrdersPlaceholder extends StatelessWidget {
  const OrdersPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Orders',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
