import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';
import 'package:baby_shop_hub/utilities/models/cart_item.dart';
import 'package:baby_shop_hub/utilities/models/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartEntry {
  final CartItem cartItem;
  final Product product;

  _CartEntry({required this.cartItem, required this.product});
}

class _CartScreenState extends State<CartScreen> {
  final MySQLService _mysqlService = MySQLService();

  List<_CartEntry> _cartEntries = [];

  // Cart item IDs selected for checkout.
  final Set<String> _selectedItems = {};

  bool _isLoading = true;
  String? _errorMessage;

  // delivery fee is fixed at 15.0 for now, but can be updated later if needed.
  static const double _deliveryFee = 15.0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ============================================================
  // LOAD CART
  // ============================================================

  Future<void> _loadCart() async {
    final userId = UserSession.instance.userId;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _cartEntries = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cartItems = await _mysqlService.getUserCart(userId);

      final List<_CartEntry> entries = [];

      for (final cartItem in cartItems) {
        try {
          final product = await _mysqlService.getProductById(
            cartItem.productId,
          );

          entries.add(_CartEntry(cartItem: cartItem, product: product));
        } catch (_) {
          // Ignore a cart item if its product no longer exists.
        }
      }

      if (!mounted) return;

      setState(() {
        _cartEntries = entries;

        // Select all loaded items by default.
        _selectedItems
          ..clear()
          ..addAll(entries.map((entry) => entry.cartItem.id));

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // UPDATE QUANTITY
  // ============================================================

  Future<void> _updateQuantity(_CartEntry entry, int newQuantity) async {
    if (newQuantity <= 0) {
      await _deleteItem(entry);
      return;
    }

    if (newQuantity > entry.product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only ${entry.product.quantity} item(s) available in stock.',
          ),
        ),
      );
      return;
    }

    try {
      await _mysqlService.updateCartQuantity(entry.cartItem.id, newQuantity);

      await _loadCart();
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteItem(_CartEntry entry) async {
    try {
      await _mysqlService.deleteCartItem(entry.cartItem.id);

      _selectedItems.remove(entry.cartItem.id);

      await _loadCart();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // SELECTION
  // ============================================================

  void _toggleSelection(String cartItemId) {
    setState(() {
      if (_selectedItems.contains(cartItemId)) {
        _selectedItems.remove(cartItemId);
      } else {
        _selectedItems.add(cartItemId);
      }
    });
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  List<_CartEntry> get _selectedEntries {
    return _cartEntries.where((entry) {
      return _selectedItems.contains(entry.cartItem.id);
    }).toList();
  }

  double get _subtotal {
    return _selectedEntries.fold(0.0, (total, entry) {
      return total + (entry.product.price * entry.cartItem.quantity);
    });
  }

  double get _discount {
    return _selectedEntries.fold(0.0, (total, entry) {
      return total +
          (entry.product.price *
              entry.cartItem.quantity *
              entry.product.discount /
              100);
    });
  }

  double get _total {
    return _subtotal + _deliveryFee - _discount;
  }

  int get _totalItemQuantity {
    return _cartEntries.fold(0, (total, entry) {
      return total + entry.cartItem.quantity;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: const Color(0xFFFFF8F4),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6600)),
        ),
      );
    }

    if (_cartEntries.isEmpty) {
      return _buildEmptyCart(context);
    }

    return Container(
      color: const Color(0xFFFFF8F4),
      child: RefreshIndicator(
        color: const Color(0xFFFF6600),
        onRefresh: _loadCart,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              _buildCartHeader(),

              const SizedBox(height: 14),

              _buildDeliveryMessage(),

              const SizedBox(height: 14),

              ..._cartEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCartItem(entry),
                ),
              ),

              const SizedBox(height: 6),

              _buildOrderSummary(),

              const SizedBox(height: 18),

              _buildCheckoutButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildCartHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(color: Color(0xFFFFF7F3)),
      child: Row(
        children: [
          const Text(
            'Your Cart',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 5),

          SvgPicture.asset('assets/cart_Icon.svg', width: 18, height: 18),

          const Spacer(),

          Text(
            '$_totalItemQuantity '
            '${_totalItemQuantity == 1 ? 'item' : 'items'}',
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELIVERY MESSAGE
  // ============================================================

  Widget _buildDeliveryMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD7C2)),
      ),
      child: const Text(
        'Delivery fee will be calculated during checkout.',
        style: TextStyle(
          fontSize: 10,
          color: Colors.deepOrange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _buildCartItem(_CartEntry entry) {
    final cartItem = entry.cartItem;
    final product = entry.product;

    final isSelected = _selectedItems.contains(cartItem.id);

    final itemTotal = product.price * cartItem.quantity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFC6A5) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // CHECK BUTTON
          // ======================================================
          GestureDetector(
            onTap: () {
              _toggleSelection(cartItem.id);
            },
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 27, right: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF6600) : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6600)
                      : const Color(0xFFD0D0D0),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
          ),

          // ======================================================
          // PRODUCT IMAGE
          // ======================================================
          _ProductImage(productId: product.id),

          const SizedBox(width: 12),

          // ======================================================
          // PRODUCT DETAILS
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '₦${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),

                if (product.quantity <= 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Out of stock',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 9),

                Row(
                  children: [
                    _quantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        _updateQuantity(entry, cartItem.quantity - 1);
                      },
                    ),

                    const SizedBox(width: 10),

                    Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: 10),

                    _quantityButton(
                      icon: Icons.add,
                      onPressed: cartItem.quantity < product.quantity
                          ? () {
                              _updateQuantity(entry, cartItem.quantity + 1);
                            }
                          : null,
                    ),

                    const Spacer(),

                    Text(
                      '₦${itemTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF273143),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ======================================================
          // DELETE
          // ======================================================
          IconButton(
            onPressed: () {
              _deleteItem(entry);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER SUMMARY
  // ============================================================

  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 14),

          _summaryRow('Subtotal', '₦${_subtotal.toStringAsFixed(2)}'),

          const SizedBox(height: 8),

          _summaryRow('Delivery Fee', '₦${_deliveryFee.toStringAsFixed(2)}'),

          const SizedBox(height: 8),

          _summaryRow('Discount', '-₦${_discount.toStringAsFixed(2)}'),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE8E8E8)),
          ),

          _summaryRow('Total', '₦${_total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  // ============================================================
  // CHECKOUT BUTTON
  // ============================================================

  Widget _buildCheckoutButton() {
    final hasSelectedItems = _selectedEntries.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _selectedEntries.isEmpty
            ? null
            : () {
                final selectedCartItemIds = _selectedEntries
                    .map((entry) => entry.cartItem.id)
                    .toList();

                context.push('/checkout/address', extra: selectedCartItemIds);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6800),
          disabledBackgroundColor: const Color(0xFFD8D8D8),
          foregroundColor: Colors.white,
          shadowColor: const Color(0x40000000),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          hasSelectedItems
              ? 'Proceed to Checkout · '
                    '₦${_total.toStringAsFixed(2)}'
              : 'Select Items to Checkout',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget _buildEmptyCart(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8F4),
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(color: Color(0xFFFFF7F3)),
              child: Row(
                children: [
                  const Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(width: 5),

                  SvgPicture.asset(
                    'assets/cart_Icon.svg',
                    width: 18,
                    height: 18,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            SvgPicture.asset('assets/cart_Icon.svg', width: 70, height: 70),

            const SizedBox(height: 20),

            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Looks like you haven\'t added anything '
              'to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6800),
                  foregroundColor: Colors.white,
                  shadowColor: const Color(0x40000000),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUANTITY BUTTON
  // ============================================================

  static Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 25,
      height: 25,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFFD9D9D9)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onPressed == null ? Colors.grey : Colors.black,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

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
            fontSize: isTotal ? 13 : 10,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 10,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFFF6800) : Colors.black,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PRODUCT IMAGE FROM MYSQL
// ============================================================

class _ProductImage extends StatefulWidget {
  final String productId;

  const _ProductImage({required this.productId});

  @override
  State<_ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<_ProductImage> {
  final MySQLService _mysqlService = MySQLService();

  Uint8List? _image;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final image = await _mysqlService.getProductImage(widget.productId);

      if (!mounted) return;

      setState(() {
        _image = image;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF6600),
              ),
            )
          : _image == null || _image!.isEmpty
          ? const Icon(
              Icons.image_not_supported_outlined,
              size: 30,
              color: Color(0xFFB8BDC6),
            )
          : Image.memory(_image!, width: 75, height: 75, fit: BoxFit.contain),
    );
  }
}
