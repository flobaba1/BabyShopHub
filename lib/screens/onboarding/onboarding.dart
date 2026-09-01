import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/core/onboarding_service.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    // 1. Persist the flag so onboarding won't show again
    await OnboardingService.completeOnboarding();

    // 2. Navigate to Login
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Onboarding Screen'),
      ),
    );
  }
}