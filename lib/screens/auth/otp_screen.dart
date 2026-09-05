import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color orange = Color(0xFFFF6500);
    const Color darkText = Color(0xFF111827);
    const Color greyText = Color(0xFF6B7280);
    const Color inputBackground = Color(0xFFFFF7ED);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // TOP BACK BUTTON
              // =========================
              const SizedBox(height: 12),

              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 21,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 38),

              // =========================
              // TITLE
              // =========================
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 8),

              // =========================
              // DESCRIPTION
              // =========================
              const Text(
                'Enter the 6-digit code sent to your email',
                style: TextStyle(fontSize: 15.5, color: greyText),
              ),

              const SizedBox(height: 40),

              // =========================
              // OTP LABEL
              // =========================
              const Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // OTP BOXES
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 51,
                    height: 58,
                    child: TextField(
                      textAlign: TextAlign.center,

                      keyboardType: TextInputType.number,

                      maxLength: 1,

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),

                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: inputBackground,

                        contentPadding: EdgeInsets.zero,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: orange.withOpacity(0.15),
                            width: 1,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: orange,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 25),

              // =========================
              // RESEND OTP
              // =========================
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(fontSize: 14, color: greyText),
                    ),

                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              // =========================
              // SUBMIT BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    elevation: 7,
                    shadowColor: orange.withOpacity(0.35),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // =========================
              // BACK TO SIGN IN
              // =========================
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Sign In',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: orange,
                    ),
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
