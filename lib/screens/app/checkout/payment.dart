import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutPaymentScreen extends StatelessWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text(
                      'Checkout',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            // Checkout progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Row(
                children: [
                  _buildStep(
                    icon: Icons.check,
                    label: 'Address',
                    completed: true,
                    active: false,
                  ),
                  _buildLine(true),
                  _buildStep(
                    number: '2',
                    label: 'Payment',
                    completed: false,
                    active: true,
                  ),
                  _buildLine(false),
                  _buildStep(
                    number: '3',
                    label: 'Review',
                    completed: false,
                    active: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Credit / Debit Card
                    _buildPaymentOption(
                      icon: Icons.credit_card_outlined,
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, Mastercard, Amex',
                      selected: true,
                      onTap: () {},
                    ),

                    const SizedBox(height: 10),

                    // Apple Pay
                    _buildPaymentOption(
                      icon: Icons.apple,
                      title: 'Apple Pay',
                      subtitle: 'Touch ID secured',
                      selected: false,
                      onTap: () {},
                    ),

                    const SizedBox(height: 10),

                    // Cash on Delivery
                    _buildPaymentOption(
                      icon: Icons.payments_outlined,
                      title: 'Cash on Delivery',
                      subtitle: 'Pay when you receive',
                      selected: false,
                      onTap: () {},
                    ),

                    const SizedBox(height: 22),

                    // Card details
                    const Text(
                      'Card Number',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 6),

                    _buildTextField(
                      initialValue: '4242 4242 4242 4242',
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Expiry',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildTextField(
                                initialValue: '08/28',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CVV',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildTextField(
                                initialValue: '•••',
                                suffixIcon: Icons.lock_outline,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Review Order
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/checkout/review');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Review Order →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF7F3)
              : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected
                ? Colors.deepOrange
                : const Color(0xFFE1E1E1),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? Colors.deepOrange
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.deepOrange,
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField({
    required String initialValue,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: suffixIcon != null,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                size: 15,
                color: Colors.grey,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFFD9D9D9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFFD9D9D9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }

  static Widget _buildStep({
    String? number,
    IconData? icon,
    required String label,
    required bool completed,
    required bool active,
  }) {
    return Column(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed || active
                ? Colors.deepOrange
                : const Color(0xFFE8E8E8),
          ),
          alignment: Alignment.center,
          child: completed
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                )
              : Text(
                  number!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: active
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: active || completed
                ? FontWeight.w600
                : FontWeight.normal,
            color: active
                ? Colors.deepOrange
                : completed
                    ? Colors.grey
                    : Colors.grey,
          ),
        ),
      ],
    );
  }

  static Widget _buildLine(bool active) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(
          bottom: 18,
          left: 5,
          right: 5,
        ),
        color: active
            ? Colors.deepOrange
            : const Color(0xFFE0E0E0),
      ),
    );
  }
}
