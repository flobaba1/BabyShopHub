import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/router.dart';

void main() {
  runApp(const BabyShopApp());
}

class BabyShopApp extends StatelessWidget {
  const BabyShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Baby Shop E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBFBFB),
      ),
      routerConfig: appRouter,
    );
  }
}