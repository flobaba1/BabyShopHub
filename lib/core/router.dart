import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ==============================
// AUTH
// ==============================
import 'package:baby_shop_hub/screens/auth/login.dart';
import 'package:baby_shop_hub/screens/auth/signup.dart';
import 'package:baby_shop_hub/screens/auth/forgotPassword.dart';
import 'package:baby_shop_hub/screens/auth/checkEmail.dart';
import 'package:baby_shop_hub/screens/auth/OTPauth.dart';

// ==============================
// ONBOARDING
// ==============================
import 'package:baby_shop_hub/screens/onboarding/onboarding.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding2.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding_three.dart';

// ==============================
// MAIN APP
// ==============================
import 'package:baby_shop_hub/screens/app/main_shell.dart';
import 'package:baby_shop_hub/screens/app/homescreen/homescreen.dart';
import 'package:baby_shop_hub/screens/app/categories/categories.dart';
import 'package:baby_shop_hub/screens/app/cart/cart.dart';

// ==============================
// PRODUCTS
// ==============================
import 'package:baby_shop_hub/screens/app/products/all_products.dart';
import 'package:baby_shop_hub/screens/app/products/filtered_products.dart';

// ==============================
// CHECKOUT
// ==============================
import 'package:baby_shop_hub/screens/app/checkout/address.dart';
import 'package:baby_shop_hub/screens/app/checkout/payment.dart';
import 'package:baby_shop_hub/screens/app/checkout/review.dart';
import 'package:baby_shop_hub/screens/app/checkout/order_success.dart';

// ==============================
// PROFILE
// ==============================
import 'package:baby_shop_hub/screens/Profile/my_orders_screen.dart';
import 'package:baby_shop_hub/screens/Profile/profile_screen.dart';

// ==============================
// ADMIN
// ==============================
import 'package:baby_shop_hub/screens/admin/admin_panel_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialRoute) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,

    initialLocation: initialRoute,

    routes: [
      // ============================================================
      // AUTHENTICATION
      // ============================================================
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) {
          return const ForgotPassword();
        },
      ),

      GoRoute(
        path: '/checkEmail',
        builder: (context, state) {
          final email = state.extra as String? ?? 'you@example.com';

          return CheckEmailScreen(email: email);
        },
      ),

      GoRoute(
        path: '/otp',
        builder: (context, state) {
          return const OtpScreen();
        },
      ),

      // ============================================================
      // ONBOARDING
      // ============================================================
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          return const OnboardingScreen();
        },
      ),

      GoRoute(
        path: '/onboarding2',
        builder: (context, state) {
          return const OnboardingScreenTwo();
        },
      ),

      GoRoute(
        path: '/onboarding3',
        builder: (context, state) {
          return const FastSafeDeliveryScreen();
        },
      ),

      // Keep this route too in case another screen already uses it.
      GoRoute(
        path: '/onboarding-three',
        builder: (context, state) {
          return const FastSafeDeliveryScreen();
        },
      ),

      // ============================================================
      // PRODUCTS
      // ============================================================
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

      // ============================================================
      // ADMIN
      // ============================================================
      GoRoute(
        path: '/admin',
        builder: (context, state) {
          return const AdminPanelScreen();
        },
      ),

      // ============================================================
      // MAIN APPLICATION SHELL
      // ============================================================
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return MainShell(navigationShell: navigationShell);
            },

        branches: [
          // ========================================================
          // BRANCH 0 — HOME
          // ========================================================
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

          // ========================================================
          // BRANCH 1 — CATEGORIES
          // ========================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) {
                  return const CategoriesScreen();
                },
              ),
            ],
          ),

          // ========================================================
          // BRANCH 2 — CART
          // ========================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) {
                  return const CartScreen();
                },
              ),
            ],
          ),

          // ========================================================
          // BRANCH 3 — ORDERS
          // ========================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) {
                  return const MyOrdersScreen();
                },
              ),
            ],
          ),

          // ========================================================
          // BRANCH 4 — PROFILE
          // ========================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfileScreen();
                },
              ),
            ],
          ),
        ],
      ),

      // ============================================================
      // CHECKOUT
      // ============================================================
      GoRoute(
        path: '/checkout/address',
        builder: (context, state) {
          final selectedCartItemIds =
              (state.extra as List<dynamic>?)
                  ?.map((id) => id.toString())
                  .toList() ??
              [];

          return CheckoutAddressScreen(
            selectedCartItemIds: selectedCartItemIds,
          );
        },
      ),

      GoRoute(
        path: '/checkout/payment',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          final selectedCartItemIds =
              (data['selectedCartItemIds'] as List<dynamic>)
                  .map((id) => id.toString())
                  .toList();

          final address = Map<String, String>.from(data['address'] as Map);

          return CheckoutPaymentScreen(
            selectedCartItemIds: selectedCartItemIds,
            address: address,
          );
        },
      ),

      GoRoute(
        path: '/checkout/review',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          final selectedCartItemIds =
              (data['selectedCartItemIds'] as List<dynamic>)
                  .map((id) => id.toString())
                  .toList();

          final address = Map<String, String>.from(data['address'] as Map);

          final paymentMethod = data['paymentMethod'].toString();

          return CheckoutReviewScreen(
            selectedCartItemIds: selectedCartItemIds,
            address: address,
            paymentMethod: paymentMethod,
          );
        },
      ),

      // ============================================================
      // ORDER SUCCESS
      // ============================================================
      GoRoute(
        path: '/order-success',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          final orderId = data['orderId'].toString();

          final total = (data['total'] as num).toDouble();

          return OrderSuccessScreen(orderId: orderId, total: total);
        },
      ),
    ],
  );
}
