import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_shop_hub/screens/auth/login.dart';
import 'package:baby_shop_hub/screens/auth/signup.dart';
import 'package:baby_shop_hub/screens/app/main_shell.dart';
import 'package:baby_shop_hub/screens/app/homescreen/homescreen.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding.dart';
import 'package:baby_shop_hub/screens/auth/forgotPassword.dart';
//import 'package:baby_shop_hub/screens/app/products/all_products.dart';
//import 'package:baby_shop_hub/screens/app/products/filtered_products.dart';
import 'package:baby_shop_hub/screens/app/dashboard/dashboard.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding2.dart';
import 'package:baby_shop_hub/screens/app/categories/categories.dart';
import 'package:baby_shop_hub/screens/app/dashboard/dashboard.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding_three.dart';
import 'package:baby_shop_hub/screens/app/cart/cart.dart';
import 'package:baby_shop_hub/screens/app/checkout/address.dart';
import 'package:baby_shop_hub/screens/app/checkout/payment.dart';
import 'package:baby_shop_hub/screens/app/checkout/review.dart';
import 'package:baby_shop_hub/screens/auth/checkEmail.dart';
import 'package:baby_shop_hub/screens/admin/admin_panel_screen.dart'; // Add this import

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialRoute) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,

    initialLocation: initialRoute,

    routes: [
      // AUTH / ONBOARDING
      // GoRoute(
      //   path: '/products',
      //   builder: (context, state) {
      //     return const AllProductsScreen();
      //   },
      // ),

      // GoRoute(
      //   path: '/products/filter',
      //   builder: (context, state) {
      //     return const FilteredProductsScreen();
      //   },
      // ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPassword(),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding-two',
        builder: (context, state) => const OnboardingScreenTwo(),
      ),
      GoRoute(
        path: '/checkEmail',
        builder: (context, state) {
          final email = state.extra as String? ?? 'you@example.com';
          return CheckEmailScreen(email: email);
        },
      ),

      // Admin Panel Route
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/onboarding-three',
        builder: (context, state) => const FastSafeDeliveryScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },

        branches: [
          // Tab 1: Home Dashboard
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

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // Tab 2: Categories Screen
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/checkout/address',
        builder: (context, state) => const CheckoutAddressScreen(),
      ),
      GoRoute(
        path: '/checkout/payment',
        builder: (context, state) => const CheckoutPaymentScreen(),
      ),
      GoRoute(
        path: '/checkout/review',
        builder: (context, state) => const CheckoutReviewScreen(),
      ),
    ],
  );
}
