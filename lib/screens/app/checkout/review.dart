import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';
import 'package:baby_shop_hub/utilities/models/cart_item.dart';
import 'package:baby_shop_hub/utilities/models/product.dart';

class CheckoutReviewScreen extends StatefulWidget {
  final List<String> selectedCartItemIds;
  final Map<String, String> address;
  final String paymentMethod;

  const CheckoutReviewScreen({
    super.key,
    required this.selectedCartItemIds,
    required this.address,
    required this.paymentMethod,
  });

  @override
  State<CheckoutReviewScreen> createState() =>
      _CheckoutReviewScreenState();
}

class _CheckoutReviewScreenState
    extends State<CheckoutReviewScreen> {
  final MySQLService _mysqlService = MySQLService();

  bool _loading = true;
  bool _placingOrder = false;

  String? _error;

  List<_ReviewItem> _items = [];

  double _subtotal = 0.0;
  double _discount = 0.0;

  // Your current cart implementation uses zero delivery fee
  // until the actual delivery pricing rule is decided.
  double _shippingFee = 0.0;

  double get _total =>
      _subtotal - _discount + _shippingFee;

  @override
  void initState() {
    super.initState();
    _loadReviewItems();
  }

  Future<void> _loadReviewItems() async {
    final userId = UserSession.instance.userId;

    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Please log in to continue.';
      });
      return;
    }

    try {
      final cartItems =
          await _mysqlService.getUserCart(userId);

      final selectedCartItems = cartItems
          .where(
            (item) => widget.selectedCartItemIds
                .contains(item.id),
          )
          .toList();

      if (selectedCartItems.isEmpty) {
        throw Exception(
          'No selected items were found in your cart.',
        );
      }

      final reviewItems = <_ReviewItem>[];

      double subtotal = 0.0;
      double discount = 0.0;

      for (final cartItem in selectedCartItems) {
        final product =
            await _mysqlService.getProductById(
          cartItem.productId,
        );

        final itemSubtotal =
            product.price * cartItem.quantity;

        final itemDiscount =
            itemSubtotal *
                (product.discount / 100);

        subtotal += itemSubtotal;
        discount += itemDiscount;

        reviewItems.add(
          _ReviewItem(
            cartItem: cartItem,
            product: product,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _items = reviewItems;
        _subtotal = subtotal;
        _discount = discount;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  String _formattedAddress() {
    return '${widget.address['street']}, '
        '${widget.address['city']}, '
        '${widget.address['state']} '
        '${widget.address['zipCode']}';
  }

  Future<void> _placeOrder() async {
    if (_placingOrder) return;

    final userId = UserSession.instance.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in to place your order.',
          ),
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'There are no items to order.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _placingOrder = true;
    });

    try {
      final shippingAddress =
          '${widget.address['fullName']}\n'
          '${widget.address['phone']}\n'
          '${widget.address['street']}, '
          '${widget.address['city']}, '
          '${widget.address['state']} '
          '${widget.address['zipCode']}';

      final orderId =
          await _mysqlService.createOrder(
        userId: userId,
        cartItemIds: widget.selectedCartItemIds,
        shippingAddress: shippingAddress,
        paymentMethod: widget.paymentMethod,
      );

      if (!mounted) return;

      context.go(
        '/order-success',
        extra: {
          'orderId': orderId,
          'total': _total,
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _placingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  String _money(double value) {
    return '₦${value.toStringAsFixed(2)}';
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
                    onPressed: _placingOrder
                        ? null
                        : () => context.pop(),
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
                    label: 'Address',
                    completed: true,
                    active: false,
                  ),
                  _buildLine(true),
                  _buildStep(
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
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    )
                  : _error != null
                      ? _buildError()
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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

                              _buildSection(
                                title: 'Delivering to',
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.address[
                                              'fullName'] ??
                                          '',
                                      style:
                                          const TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      _formattedAddress(),
                                      style:
                                          const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      widget.address[
                                              'phone'] ??
                                          '',
                                      style:
                                          const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              _buildSection(
                                title: 'Payment',
                                child: Row(
                                  children: [
                                    Icon(
                                      _paymentIcon(),
                                      size: 21,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      widget.paymentMethod,
                                      style:
                                          const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              _buildSection(
                                title:
                                    'Items (${_items.length})',
                                child: Column(
                                  children: _items
                                      .map(
                                        (item) =>
                                            _buildItem(item),
                                      )
                                      .toList(),
                                ),
                              ),

                              const SizedBox(height: 14),

                              _buildSection(
                                title: 'Order Summary',
                                child: Column(
                                  children: [
                                    _summaryRow(
                                      'Subtotal',
                                      _money(_subtotal),
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    _summaryRow(
                                      'Discount',
                                      '-${_money(_discount)}',
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    _summaryRow(
                                      'Delivery',
                                      _shippingFee == 0
                                          ? 'Free'
                                          : _money(
                                              _shippingFee,
                                            ),
                                    ),

                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color:
                                            Color(0xFFE8E8E8),
                                      ),
                                    ),

                                    _summaryRow(
                                      'Total',
                                      _money(_total),
                                      isTotal: true,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed:
                                      _placingOrder
                                          ? null
                                          : _placeOrder,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.deepOrange,
                                    foregroundColor:
                                        Colors.white,
                                    disabledBackgroundColor:
                                        Colors.deepOrange
                                            .withOpacity(0.6),
                                    elevation: 4,
                                    shadowColor:
                                        Colors.black26,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(25),
                                    ),
                                  ),
                                  child: _placingOrder
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                                Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Place Order · ${_money(_total)}',
                                          style:
                                              const TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.bold,
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

  IconData _paymentIcon() {
    switch (widget.paymentMethod) {
      case 'Apple Pay':
        return Icons.apple;

      case 'Cash on Delivery':
        return Icons.payments_outlined;

      default:
        return Icons.credit_card_outlined;
    }
  }

  Widget _buildItem(_ReviewItem item) {
    return FutureBuilder<Uint8List?>(
      future: _mysqlService.getProductImage(
        item.product.id,
      ),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius:
                      BorderRadius.circular(7),
                ),
                child: snapshot.hasData
                    ? Image.memory(
                        snapshot.data!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 25,
                      ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quantity: ${item.cartItem.quantity}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _money(
                  item.product.price *
                      item.cartItem.quantity,
                ),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loadReviewItems,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 12 : 10,
            fontWeight: isTotal
                ? FontWeight.bold
                : FontWeight.normal,
            color: isTotal
                ? Colors.black
                : Colors.grey,
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
            fontWeight:
                active || completed
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

class _ReviewItem {
  final CartItem cartItem;
  final Product product;

  _ReviewItem({
    required this.cartItem,
    required this.product,
  });
}
