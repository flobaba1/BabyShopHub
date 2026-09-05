import 'package:flutter/material.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:baby_shop_hub/utilities/email_sender.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/utilities/crypto_util.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  
  final TextEditingController _emailController = TextEditingController();
  final MySQLService mysqlService = MySQLService();
  void _validateEmailAndSendPassword() {
    final email = _emailController.text.trim();
    EasyLoading.show(status: 'Processing...');

    if (email.isEmpty) {
      EasyLoading.showToast('Please enter your email address.');
      return;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',).hasMatch(email)) {
        EasyLoading.showToast('Please enter a valid email address.');
        return;
    }

    mysqlService.validateUserEmail(email).then((User? user) {
      if (user == null) {
        EasyLoading.showToast('No account found with this email address.');
        return;
      }
      
      // Generate 12-character secure random password using CryptoUtils
    final String newPassword = CryptoUtils.generateRandomPassword(length: 12);

      EmailService.resetPassword(recipientEmail: email, recipientName: user.fullName.split(' ').first, newPlainPassword: newPassword).then((bool isEmailSent) {
        if (isEmailSent) {

          mysqlService.updateUserPassword(userId: user.id, newPlainPassword: newPassword).then((bool isPasswordUpdated) {
            if (isPasswordUpdated) {
              EasyLoading.dismiss();
              EasyLoading.showToast('Password reset email sent successfully.');
              context.pop(); // Navigate back to the previous screen
            } else {
              EasyLoading.dismiss();
              EasyLoading.showError('Failed to update password. Please try again later.');
            }
          }).catchError((error) {
            EasyLoading.dismiss();
            EasyLoading.showError('Service temporarily unavailable. Please try again later.');
          });
        } else {
          EasyLoading.dismiss();
          EasyLoading.showError('Failed to send password reset email. Please try again later.');
        }
      }).catchError((error) {
        EasyLoading.dismiss();
        EasyLoading.showError('Service temporarily unavailable. Please try again later.');
      });
      // Proceed with password reset logic
      EasyLoading.showToast('Password reset email sent successfully.');
    }).catchError((error) {
      EasyLoading.dismiss();
      EasyLoading.showError('Service temporarily unavailable. Please try again later.');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Remove MaterialApp wrapper to maintain GoRouter context
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9F5),
        elevation: 0,
        centerTitle: true,
        // 2. Wrap the leading widget with GestureDetector or InkWell
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/login'); // Fallback route if direct navigation occurs
              }
            },
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
              "send you a new password.",
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
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
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
                onPressed: _validateEmailAndSendPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6600),
                  foregroundColor: Colors.white,
                  elevation: 7,
                  shadowColor: const Color(0x55FF6600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
