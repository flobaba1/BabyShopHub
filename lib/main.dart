import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/router.dart';
import 'package:baby_shop_hub/core/onboarding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Read first-time status before building the UI
  final bool isFirstTime = await OnboardingService.isFirstTimeUser();

  // 2. Pass the initial route dynamically
  final String initialRoute = isFirstTime ? '/onboarding' : '/login';

  runApp(BabyShopApp(initialRoute: initialRoute));
}

class BabyShopApp extends StatelessWidget {
  final String initialRoute;

  const BabyShopApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Baby Shop E-Commerce',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoStretchScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBFBFB),
      ),
      routerConfig: createRouter(initialRoute),
    );
  }
}

class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
