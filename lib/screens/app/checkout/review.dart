import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutReviewScreen extends StatelessWidget {
  const CheckoutReviewScreen({super.key});

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
                    icon: Icons.check,
                    label: 'Payment',
                    completed: true,
                    active: false,
                  ),
                  _buildLine(true),
                  _buildStep(
                    number: '3',
                    label: 'Review',
                    completed: false,
                    active: true,
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
                      'Order Review',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Delivery Address
                    _buildSection(
                      title: 'Delivering to',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Emma Johnson',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '123 Maple Street, Springfield, IL 62701',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '+1 (555) 123-4567',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Payment
                    _buildSection(
                      title: 'Payment',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.credit_card_outlined,
                            size: 21,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Credit Card',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '•••• 4242',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Items
                    _buildSection(
                      title: 'Items (1)',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child:Image.asset(
                              'assets/Diapers.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(width: 11),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Huggies Little Snugglers Diapers',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Quantity: 1',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Text(
                            '\$24.99',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Order Summary
                    _buildSection(
                      title: 'Order Summary',
                      child: Column(
                        children: [
                          _summaryRow(
                            'Subtotal',
                            '\$24.99',
                          ),
                          const SizedBox(height: 8),
                          _summaryRow(
                            'Delivery',
                            '\$4.99',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 11),
                            child: Divider(
                              height: 1,
                              color: Color(0xFFE8E8E8),
                            ),
                          ),
                          _summaryRow(
                            'Total',
                            '\$29.98',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Place Order
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Connect to order placement flow.
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
                          'Place Order · \$29.98',
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

  static Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }

  static Widget _summaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 12 : 10,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
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
                    color: active ? Colors.white : Colors.grey,
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