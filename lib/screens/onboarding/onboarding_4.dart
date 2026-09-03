import 'package:flutter/material.dart';

void main() {
  runApp(const Onboarding4());
}

class Onboarding4 extends StatelessWidget {
  const Onboarding4({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 67),

                // Welcome back
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF182235),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Sign in to your BabyShopHub account',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A8190)),
                ),

                const SizedBox(height: 30),

                // Email label
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F596B),
                  ),
                ),

                const SizedBox(height: 7),

                // Email field
                Container(
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFFFEAD3)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: Color(0xFFFF7A18),
                        size: 17,
                      ),
                      hintText: 'emma@example.com',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF394151),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Password label
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F596B),
                  ),
                ),

                const SizedBox(height: 7),

                // Password field
                Container(
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFFFEAD3)),
                  ),
                  child: const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFFFF7A18),
                        size: 17,
                      ),
                      suffixIcon: Icon(
                        Icons.visibility_outlined,
                        color: Color(0xFF8A92A1),
                        size: 18,
                      ),
                      hintText: '••••••••',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9BA1AE),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Forgot Password
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6600),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6600),
                      disabledBackgroundColor: const Color(0xFFFF6600),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 7,
                      shadowColor: const Color(0x55FF6600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E4E8))),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),

                    const Expanded(child: Divider(color: Color(0xFFE2E4E8))),
                  ],
                ),

                const SizedBox(height: 17),

                // Apple and Google floating buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 151,
                      height: 42,
                      child: FloatingActionButton.extended(
                        heroTag: 'appleButton',
                        onPressed: null,
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3C4556),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                          side: const BorderSide(color: Color(0xFFE3E5E9)),
                        ),
                        label: const Row(
                          children: [
                            Text('🍎', style: TextStyle(fontSize: 13)),
                            SizedBox(width: 5),
                            Text(
                              'Apple',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 151,
                      height: 42,
                      child: FloatingActionButton.extended(
                        heroTag: 'googleButton',
                        onPressed: null,
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3C4556),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                          side: const BorderSide(color: Color(0xFFE3E5E9)),
                        ),
                        label: const Row(
                          children: [
                            Text('🌐', style: TextStyle(fontSize: 13)),
                            SizedBox(width: 5),
                            Text(
                              'Google',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 34),

                // Sign Up
                Center(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, color: Color(0xFF737B8C)),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
