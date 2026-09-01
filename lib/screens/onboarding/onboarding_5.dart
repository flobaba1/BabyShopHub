import 'package:flutter/material.dart';

void main() {
  runApp(const Onboarding5());
}

class Onboarding5 extends StatelessWidget {
  const Onboarding5({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF9F5),
          elevation: 0,
          centerTitle: true,

          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFE8E3DE)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF536071),
              ),
            ),
          ),

          title: const Text(
            'Forgot Password',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF182235),
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Column(
            children: [
              const SizedBox(height: 23),

              // Lock icon
              Container(
                width: 73,
                height: 73,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECD4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 30,
                    color: Color(0xFFFF6600),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Reset Your Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF161616),
                ),
              ),

              const SizedBox(height: 8),

              // Description
              const Text(
                "Enter the email address linked to your account. We'll\n"
                "send you a reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.65,
                  color: Color(0xFF70798B),
                ),
              ),

              const SizedBox(height: 28),

              // Email label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F596B),
                  ),
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
                    hintText: 'you@example.com',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFA2A8B3),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Send Reset Link button
              SizedBox(
                width: double.infinity,
                height: 52,
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
                    'Send Reset Link',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
