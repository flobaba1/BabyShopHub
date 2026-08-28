import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/screens/auth/login.dart';
import 'package:baby_shop_hub/screens/auth/signup.dart';
import 'package:baby_shop_hub/screens/app/main_shell.dart';
import 'package:baby_shop_hub/screens/app/dashboard/dashboard.dart';  
import 'package:baby_shop_hub/screens/onboarding/onboarding.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding_three.dart';

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

        ],
      ),
    ],
  );
}