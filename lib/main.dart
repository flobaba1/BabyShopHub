import 'package:baby_shop_hub/screens/Profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding.dart';
import 'screens/Profile/my_orders_screen.dart';
import 'screens/Profile/track_order_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner:
          false, // Removes the red debug banner in the corner
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily:
            'Roboto', // Default fallback font, change if using custom typography
      ),
      home: const OnboardingScreen(), // Launches your onboarding screen first
    );
  }
}
