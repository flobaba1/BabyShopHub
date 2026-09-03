import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CheckoutAddressScreen extends StatelessWidget {
  const CheckoutAddressScreen({super.key});

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
                    number: '1',
                    label: 'Address',
                    active: true,
                  ),
                  _buildLine(false),
                  _buildStep(
                    number: '2',
                    label: 'Payment',
                    active: false,
                  ),
                  _buildLine(false),
                  _buildStep(
                    number: '3',
                    label: 'Review',
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
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildLabel('Full Name'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      initialValue: 'Emma Johnson',
                      iconAsset: 'assets/users_Icon.svg',
                    ),

                    const SizedBox(height: 14),

                    _buildLabel('Phone Number'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      initialValue: '+1 (555) 123-4567',
                      iconAsset: 'assets/phone_Icon.svg',
                    ),

                    const SizedBox(height: 14),

                    _buildLabel('Street Address'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      initialValue: '123 Maple Street',
                      iconAsset: 'assets/drop_pin_Icon.svg',
                    ),

                    const SizedBox(height: 14),

                    _buildLabel('City'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      initialValue: 'Springfield',
                      iconAsset: 'assets/drop_pin_Icon.svg',
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _buildLabel('State'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                initialValue: 'IL',
                                iconAsset: 'assets/drop_pin_Icon.svg',
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
                              _buildLabel('ZIP Code'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                initialValue: '62701',
                                iconAsset: 'assets/drop_pin_Icon.svg',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/checkout/payment');
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
                          'Continue to Payment →',
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

  static Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  static Widget _buildTextField({
    required String initialValue,
    required String iconAsset,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            iconAsset,
            width: 18,
            height: 18,
          ),
        ),
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
    required String number,
    required String label,
    required bool active,
  }) {
    return Column(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? Colors.deepOrange
                : const Color(0xFFE8E8E8),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: active
                ? FontWeight.w600
                : FontWeight.normal,
            color: active ? Colors.deepOrange : Colors.grey,
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
