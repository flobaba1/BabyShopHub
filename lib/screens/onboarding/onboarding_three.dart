import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/core/onboarding_service.dart';

class FastSafeDeliveryScreen extends StatelessWidget {
  const FastSafeDeliveryScreen({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
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
        //        child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 250,
                ),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF08C4CC),
                ),
                child: Column(
                  children: [
                    // Image.asset(
                    //   'assets/rocket.png',
                    //   height: 70,
                    // )  NO IMAGE YET
                    const Text(
                      '🚀',
                      style: TextStyle(
                        fontSize: 70,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Fast & Safe Delivery',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Free delivery on orders over \$50. '
                      'Real-time tracking from warehouse to your door.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 27),

              // Page indicators.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(false),
                  const SizedBox(width: 7),
                  _buildDot(false),
                  const SizedBox(width: 7),
                  _buildDot(true),
                ],
              ),

              const SizedBox(height: 22),

              // Get Started button.
              SizedBox(
                width: 274,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _finishOnboarding(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6800),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: const Color(0x40FF6800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 17),

              // Sign in link.
              GestureDetector(
                onTap: () => _finishOnboarding(context),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA3B2),
                    ),
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                      ),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Color(0xFFFF6800),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        //        ),
      ),
    );
  }

  static Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 20 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFF6800)
            : const Color(0xFFE2E5E9),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}