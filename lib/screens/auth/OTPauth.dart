import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:baby_shop_hub/utilities/email_sender.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/utilities/crypto_util.dart';
import 'package:baby_shop_hub/core/user_session.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final MySQLService _mysqlService = MySQLService();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Concatenates typed input digits
  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _resendOtp(User user) async {
    EasyLoading.show(status: 'Resending OTP...');
    final String otpCode = CryptoUtils.generateOtp(length: 6);

    final bool isOtpUpdated = await _mysqlService.updateUserOtp(
      otpId: user.metadata['otpId'], 
      newOtp: otpCode,
    );

    if (isOtpUpdated) {
      final bool isEmailSent = await EmailService.sendOtp(
        recipientEmail: user.email,
        recipientName: user.fullName.split(' ').first,
        otp: otpCode,
      );

      EasyLoading.dismiss();

      if (isEmailSent) {
        // Clear input boxes on resend
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        EasyLoading.showSuccess('OTP resent successfully!');
      } else {
        EasyLoading.showError('Failed to resend OTP. Please try again later.');
      }
    } else {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to update OTP. Please try again later.');
    }
  }

  Future<void> _submitOtp(User user) async {
    final String enteredCode = _otpCode;

    if (enteredCode.length < 6) {
      EasyLoading.showToast('Please enter the complete 6-digit verification code.');
      return;
    }

    EasyLoading.show(status: 'Verifying code...');

    try {
      final bool isValid = await _mysqlService.verifyOTP(
        otpId: user.metadata['otpId'],
        userId: user.id,
        inputCode: enteredCode,
      );

      EasyLoading.dismiss();

      if (isValid) {
        UserSession.saveUserSession(user);
        EasyLoading.showSuccess('Verification successful!');
        if (mounted) {
          context.go('/home'); // Or navigate to next screen in flow
        }
      } else {
        EasyLoading.showError('Invalid or expired verification code.');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Verification failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color orange = Color(0xFFFF6500);
    const Color darkText = Color(0xFF111827);
    const Color greyText = Color(0xFF6B7280);
    const Color inputBackground = Color(0xFFFFF7ED);

    final User user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    Navigator.pop(context);
                  }
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

              const Text(
                'Enter the 6-digit code sent to your email',
                style: TextStyle(fontSize: 15.5, color: greyText),
              ),

              const SizedBox(height: 40),

              const Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),

              const SizedBox(height: 12),

              // OTP Input Row with Auto-Focus Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 51,
                    height: 58,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }

                        // Auto-submit when last digit is filled
                        if (_otpCode.length == 6) {
                          _submitOtp(user);
                        }
                      },
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

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(fontSize: 14, color: greyText),
                    ),
                    GestureDetector(
                      onTap: () => _resendOtp(user),
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

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => _submitOtp(user),
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

              Center(
                child: GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Navigator.pop(context);
                    }
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