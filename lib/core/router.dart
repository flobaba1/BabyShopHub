import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/screens/auth/login.dart';
import 'package:baby_shop_hub/screens/auth/signup.dart';
import 'package:baby_shop_hub/screens/app/main_shell.dart';
import 'package:baby_shop_hub/screens/app/dashboard/dashboard.dart';  
import 'package:baby_shop_hub/screens/onboarding/onboarding.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding_three.dart';
import 'package:baby_shop_hub/screens/app/cart/cart.dart';
import 'package:baby_shop_hub/screens/app/checkout/address.dart';
import 'package:baby_shop_hub/screens/app/checkout/payment.dart';
import 'package:baby_shop_hub/screens/app/checkout/review.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialRoute) {
  return GoRouter(
    initialLocation: initialRoute,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
                builder: (context, state) => const DashboardScreen(),
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