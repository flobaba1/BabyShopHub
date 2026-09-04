import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_shop_hub/screens/auth/login.dart';
import 'package:baby_shop_hub/screens/auth/signup.dart';
import 'package:baby_shop_hub/screens/app/main_shell.dart';
import 'package:baby_shop_hub/screens/app/homescreen/homescreen.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding.dart';
import 'package:baby_shop_hub/screens/auth/forgotPassword.dart';
import 'package:baby_shop_hub/screens/app/dashboard/dashboard.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding2.dart';
import 'package:baby_shop_hub/screens/app/categories/categories.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding_three.dart';
import 'package:baby_shop_hub/screens/app/cart/cart.dart';
import 'package:baby_shop_hub/screens/app/checkout/address.dart';
import 'package:baby_shop_hub/screens/app/checkout/payment.dart';
import 'package:baby_shop_hub/screens/app/checkout/review.dart';
import 'package:baby_shop_hub/screens/auth/checkEmail.dart';
import 'package:baby_shop_hub/screens/admin/admin_panel_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialRoute) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,

    initialLocation: initialRoute,

    routes: [
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPassword(),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const RegisterScreen(),
      ),

      // SLIDE 1 (onboarding.dart)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // FIXED: SLIDE 2 (onboarding2.dart) -> Corrected widget target name match
      GoRoute(
        path: '/onboarding2',
        builder: (context, state) => const OnboardingScreenTwo(),
      ),

      // FIXED: SLIDE 3 (onboarding_three.dart) -> Unified path format name and widget target
      GoRoute(
        path: '/onboarding3',
        builder: (context, state) => const FastSafeDeliveryScreen(),
      ),

      GoRoute(
        path: '/checkEmail',
        builder: (context, state) {
          final email = state.extra as String? ?? 'you@example.com';
          return CheckEmailScreen(email: email);
        },
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
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
