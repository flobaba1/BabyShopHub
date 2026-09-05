import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';
import '../../../core/user_session.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  final MySQLService _mysqlService = MySQLService();

  Uint8List? _image;
  bool _imageLoading = true;
  bool _addingToCart = false;

  int _selectedQuantity = 1;
  bool _isFavorite = false;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final image =
          await _mysqlService.getProductImage(product.id);

      if (!mounted) return;

      setState(() {
        _image = image;
        _imageLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _imageLoading = false;
      });
    }
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> _addToCart() async {
    final userId = UserSession.loggedUser?.id;

    if (userId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add items to your cart.'),
        ),
      );

      return;
    }

    if (_selectedQuantity <= 0) {
      return;
    }

    setState(() {
      _addingToCart = true;
    });

    try {
      await _mysqlService.addToCart(
        userId: userId,
        productId: product.id,
        quantity: _selectedQuantity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} added to your cart.',
          ),
          backgroundColor: const Color(0xFF13A765),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              context.push('/cart');
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });
      }
    }
  }

  // ============================================================
  // BUY NOW
  // ============================================================

  Future<void> _buyNow() async {
    final userId = UserSession.loggedUser?.id;

    if (userId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to continue.'),
        ),
      );

      return;
    }

    setState(() {
      _addingToCart = true;
    });

    try {
      await _mysqlService.addToCart(
        userId: userId,
        productId: product.id,
        quantity: _selectedQuantity,
      );

      if (!mounted) return;

      // Go directly to the cart after adding the item.
      context.push('/cart');
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  _buildProductInformation(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImageSection() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: _imageLoading
                ? Container(
                    color: const Color(0xFFF1F1F1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6600),
                      ),
                    ),
                  )
                : _image == null || _image!.isEmpty
                    ? Container(
                        color: const Color(0xFFF1F1F1),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 55,
                            color: Color(0xFFB8BDC6),
                          ),
                        ),
                      )
                    : Image.memory(
                        _image!,
                        fit: BoxFit.cover,
                      ),
          ),

          // BACK
          Positioned(
            top: 45,
            left: 15,
            child: _topButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),

          // FAVORITE
          Positioned(
            top: 45,
            right: 15,
            child: _topButton(
              icon: _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: _isFavorite
                  ? const Color(0xFFFF3D3D)
                  : const Color(0xFF273143),
              onTap: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
            ),
          ),

          // DISCOUNT
          if (product.discount > 0)
            Positioned(
              left: 15,
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF13A765),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '${product.discount.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF273143),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x15000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT INFORMATION
  // ============================================================

  Widget _buildProductInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        25,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.brand != null &&
              product.brand!.trim().isNotEmpty)
            Text(
              product.brand!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF6600),
              ),
            ),

          const SizedBox(height: 6),

          Text(
            product.name,
            style: const TextStyle(
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Color(0xFF273143),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 19,
                color: Color(0xFFFFB000),
              ),
              const SizedBox(width: 4),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF273143),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFD2D4D8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                product.quantity > 0
                    ? '${product.quantity} in stock'
                    : 'Out of stock',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: product.quantity > 0
                      ? const Color(0xFF13A765)
                      : const Color(0xFFFF3D3D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                '₦${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF202938),
                ),
              ),

              if (product.discount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F8F0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Save ${product.discount.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF13A765),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          const Divider(
            color: Color(0xFFEAEAEA),
          ),

          const SizedBox(height: 18),

          const Text(
            'Description',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF273143),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            product.description != null &&
                    product.description!.trim().isNotEmpty
                ? product.description!
                : 'No description available for this product.',
            style: const TextStyle(
              fontSize: 12,
              height: 1.55,
              color: Color(0xFF737A86),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Quantity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF273143),
            ),
          ),

          const SizedBox(height: 10),

          _buildQuantitySelector(),
        ],
      ),
    );
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: const Color(0xFFE4E4E4),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _selectedQuantity > 1
                    ? () {
                        setState(() {
                          _selectedQuantity--;
                        });
                      }
                    : null,
                icon: const Icon(
                  Icons.remove,
                  size: 17,
                ),
              ),

              SizedBox(
                width: 30,
                child: Text(
                  '$_selectedQuantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF273143),
                  ),
                ),
              ),

              IconButton(
                onPressed:
                    _selectedQuantity < product.quantity
                        ? () {
                            setState(() {
                              _selectedQuantity++;
                            });
                          }
                        : null,
                icon: const Icon(
                  Icons.add,
                  size: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM ACTIONS
  // ============================================================

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    product.quantity <= 0 || _addingToCart
                        ? null
                        : _addToCart,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                  side: const BorderSide(
                    color: Color(0xFFFF6600),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _addingToCart
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF6600),
                        ),
                      )
                    : const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Color(0xFFFF6600),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed:
                    product.quantity <= 0 || _addingToCart
                        ? null
                        : _buyNow,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                  backgroundColor: const Color(0xFFFF6600),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

