import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double total;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFE4D8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 55,
                  color: Colors.deepOrange,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Thank you for your purchase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Order Number',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      orderId,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Divider(
                      color: Color(0xFFE8E8E8),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '₦${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/orders');
                  },
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
                    'View My Orders',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.deepOrange,
                    side: const BorderSide(
                      color: Colors.deepOrange,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
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
    );
  }
}
