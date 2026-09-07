import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final MySQLService _mysqlService = MySQLService();
  final UserSession _userSession = UserSession.instance;

  bool _isDefault = true;
  bool _isSaving = false;

  // FIXED: Moved controllers outside the build block so they do not crash your cursor typing!
  final _holderController = TextEditingController(text: 'Emma Johnson');
  final _numberController = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryController = TextEditingController(text: '12/26');
  final _cvvController = TextEditingController(text: '123');

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATABASE TRANSACTION: SAVING CARD SCHEMAS SECURELY
  // ============================================================
  Future<void> _savePaymentMethod() async {
    final String? userId = _userSession.userId;
    if (userId == null) return;

    final holder = _holderController.text.trim();
    final number = _numberController.text.trim().replaceAll(' ', '');
    final expiry = _expiryController.text.trim();

    if (holder.isEmpty || number.isEmpty || expiry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all card entry fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    EasyLoading.show(status: 'Encrypting card verification token...');

    // Extract the final 4 digits to store inside your MySQL table securely
    final lastFour = number.length >= 4
        ? number.substring(number.length - 4)
        : '0000';

    try {
      // NOTE: This is where you would call Paystack/Flutterwave SDK to tokenise!
      // Example: String gatewayToken = await PaystackPlugin.chargeCard(context, card);
      final String mockGatewayToken =
          'tok_paystack_${DateTime.now().millisecondsSinceEpoch}';

      final bool success = await _mysqlService.addUserCard(
        userId: userId,
        cardHolder: holder,
        cardLastFour: lastFour,
        expiryDate: expiry,
        cardToken: mockGatewayToken,
      );

      if (!mounted) return;

      if (success) {
        EasyLoading.showSuccess('Payment method added successfully!');
        Navigator.pop(
          context,
          true,
        ); // Pop backwards with a success flag trigger
      } else {
        EasyLoading.showError('Could not write to user records.');
      }
    } catch (e) {
      EasyLoading.showError('Secure Save Error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Payment Method',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _buildTabItem('Card', true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTabItem('PayPal', false)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTabItem('Other', false)),
                ],
              ),
              const SizedBox(height: 24),

              _buildInputField('Cardholder Name', _holderController),
              const SizedBox(height: 16),
              _buildInputField(
                'Card Number',
                _numberController,
                suffix: 'VISA',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      'Expiry Date',
                      _expiryController,
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      'CVV',
                      _cvvController,
                      suffixIcon: Icons.help_outline_rounded,
                      keyboardType: TextInputType.number,
                      obscure: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Billing Address',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        '123 Maple Street, Apt 4B\nSpringfield, IL 62704, USA',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set as default payment method',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val),
                    activeThumbColor: const Color(0xFFFF6D00),
                    activeTrackColor: const Color(0xFFFF6D00).withOpacity(0.2),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Payment Method',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildTabItem(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF6D00) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? suffix,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey, size: 18)
                : (suffix != null
                      ? Container(
                          alignment: Alignment.centerRight,
                          width: 50,
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            suffix,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF6D00)),
            ),
          ),
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}
