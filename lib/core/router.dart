
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_shop_hub/screens/auth/login.dart';
import 'package:baby_shop_hub/screens/auth/signup.dart';
import 'package:baby_shop_hub/screens/app/main_shell.dart';
import 'package:baby_shop_hub/screens/app/dashboard/dashboard.dart';
import 'package:baby_shop_hub/screens/app/categories/categories.dart';
import 'package:baby_shop_hub/screens/onboarding/onboarding2.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialRoute) {
  return GoRouter(
    // Force initialLocation to '/categories' temporarily to test your screen:
    initialLocation: '/categories', 
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
        builder: (context, state) => const OnboardingScreenTwo(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
          );
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
    ],
  );
}