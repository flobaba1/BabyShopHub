import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/router.dart';
import 'package:baby_shop_hub/core/onboarding_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Read first-time status before building the UI
  final bool isFirstTime = await OnboardingService.isFirstTimeUser();

  // 2. Pass the initial route dynamically
  final String initialRoute = isFirstTime ? '/onboarding' : '/login';

  runApp(BabyShopApp(initialRoute: initialRoute));

  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..maskType = EasyLoadingMaskType.black; // Blurs/darkens background
}

class BabyShopApp extends StatelessWidget {
  final String initialRoute;

  BabyShopApp({super.key, required this.initialRoute});

  final MySQLService mysqlService = MySQLService();

  Future<void> _initializeMySQL() async {
    try {
      await mysqlService.connection;
    } catch (e) {
      log("Error connecting to MySQL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeMySQL();
    return MaterialApp.router(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoStretchScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily:
            'Roboto', // Default fallback font, change if using custom typography
      ),
      routerConfig: createRouter(initialRoute),

      builder: EasyLoading.init(),
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
