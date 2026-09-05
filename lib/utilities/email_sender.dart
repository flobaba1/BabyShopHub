import 'package:baby_shop_hub/env/env.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:baby_shop_hub/utilities/crypto_util.dart'; // Adjust path as needed
 
class EmailService {
  static const String _baseUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  static String _serviceId = Env.emailJsServiceId;
  static String _publicKey = Env.emailJsPublicKey;
  static String _privateKey = Env.emailJsKey;
  static String _userId = Env.emailJsUserId;

  // EmailJS Template IDs
  static String _otpTemplateId = Env.emailJsTemplateOtpId;
  static String _resetPasswordTemplateId = Env.emailJsTemplateResetPasswordId;

  /// Sends a single-use OTP to the specified [recipientEmail]
  static Future<bool> sendOtp({
    required String recipientEmail,
    required String recipientName,
    required String otp, // Default OTP length is 6 digits
  }) async {
    // Generate 6-digit numeric OTP using CryptoUtils
 
    final Map<String, dynamic> templateParams = {
      'email': recipientEmail,
      'firstName': recipientName,
      'passcode': otp,
      'companyName': 'Baby Shop Hub',
    };
 
    return _sendEmail(
      templateId: _otpTemplateId,
      templateParams: templateParams,
    );
  }
 
  /// Sends a randomly generated temporary password to the specified [recipientEmail]
  static Future<bool> resetPassword({
    required String recipientEmail,
    required String recipientName,
    required String newPlainPassword,
  }) async {
    final Map<String, dynamic> templateParams = {
      'email': recipientEmail,
      'firstName': recipientName,
      'password': newPlainPassword,
      'companyName': 'Baby Shop Hub',
    };
 
    return _sendEmail(
      templateId: _resetPasswordTemplateId,
      templateParams: templateParams,
    );
  }
 
  /// Core HTTP handler executing the EmailJS POST request
  static Future<bool> _sendEmail({
    required String templateId,
    required Map<String, dynamic> templateParams,
  }) async {
    try {
      final Uri url = Uri.parse(_baseUrl);
 
      final Map<String, dynamic> body = {
        'service_id': _serviceId,
        'template_id': templateId,
        'user_id': _publicKey,
        'accessToken': _privateKey,
        'template_params': templateParams,
      };
 
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
 
      if (response.statusCode == 200) {
        log('EmailJS: Email dispatched successfully.');
        return true;
      } else {
        log('EmailJS Error [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e) {
      log('EmailJS Exception: $e');
      return false;
    }
  }
}
