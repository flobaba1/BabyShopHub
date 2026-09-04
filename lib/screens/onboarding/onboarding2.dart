import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/core/onboarding_service.dart';

class OnboardingScreenTwo extends StatelessWidget {
  const OnboardingScreenTwo({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    // 1. Persist the flag so onboarding won't show again
    await OnboardingService.completeOnboarding();

 if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top orange section
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFF9800),
                      Color(0xFFFF7300),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(),

                      // Teddy image
                      Image.asset(
                        'assets/Teddy_Icon.png',
                        width: 140,
                        height: 140,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        '7+ Curated Categories',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'From diapers to toys, organic food to cozy clothing—all trusted brands in one place.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom white section
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 25,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Side-by-side action buttons
                    Row(
                      children: [
                        // Skip Button
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton(
                             // 2. Navigate to Login
                                  onPressed: () {
                                _finishOnboarding(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFEEEEEE)),
                                foregroundColor: Colors.grey[700],
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),

                        // Next Button with shadow matching UI
                        Expanded(
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(27),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6D00).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Connect your navigation sequence here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6D00),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Next \u2192',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Sign in section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFFFF6D00),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
