import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CheckoutAddressScreen extends StatefulWidget {
  final List<String> selectedCartItemIds;

  const CheckoutAddressScreen({
    super.key,
    required this.selectedCartItemIds,
  });

  @override
  State<CheckoutAddressScreen> createState() =>
      _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState
    extends State<CheckoutAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController =
      TextEditingController();

  final _phoneController =
      TextEditingController();

  final _streetController =
      TextEditingController();

  final _cityController =
      TextEditingController();

  final _stateController =
      TextEditingController();

  final _zipController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();

    super.dispose();
  }

  void _continueToPayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final address = {
      'fullName': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zipCode': _zipController.text.trim(),
    };

    context.push(
      '/checkout/payment',
      extra: {
        'selectedCartItemIds':
            widget.selectedCartItemIds,
        'address': address,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SafeArea(
        child: Column(
          children: [
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
                    constraints:
                        const BoxConstraints(),
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

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35),
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        controller: _fullNameController,
                        iconAsset:
                            'assets/users_Icon.svg',
                      ),

                      const SizedBox(height: 14),

                      _buildLabel('Phone Number'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _phoneController,
                        iconAsset:
                            'assets/phone_Icon.svg',
                        keyboardType:
                            TextInputType.phone,
                      ),

                      const SizedBox(height: 14),

                      _buildLabel('Street Address'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _streetController,
                        iconAsset:
                            'assets/drop_pin_Icon.svg',
                      ),

                      const SizedBox(height: 14),

                      _buildLabel('City'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _cityController,
                        iconAsset:
                            'assets/drop_pin_Icon.svg',
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
                                  controller:
                                      _stateController,
                                  iconAsset:
                                      'assets/drop_pin_Icon.svg',
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
                                  controller:
                                      _zipController,
                                  iconAsset:
                                      'assets/drop_pin_Icon.svg',
                                  keyboardType:
                                      TextInputType.number,
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
                          onPressed: _continueToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.deepOrange,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.black26,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(25),
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
    required TextEditingController controller,
    required String iconAsset,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.black,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            iconAsset,
            width: 18,
            height: 18,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
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
            fontWeight: active
                ? FontWeight.w600
                : FontWeight.normal,
            color: active
                ? Colors.deepOrange
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

