import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final MySQLService _mysqlService = MySQLService();

  Uint8List? _image;
  bool _loadingImage = true;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final image = await _mysqlService.getProductImage(
        widget.product.id,
      );

      if (!mounted) return;

      setState(() {
        _image = image;
        _loadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool inStock = product.quantity > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 181,
                          child: _buildImage(),
                        ),

                        Positioned(
                          top: 12,
                          left: 12,
                          child: _topButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),

                        Positioned(
                          top: 12,
                          right: 12,
                          child: _topButton(
                            icon: Icons.favorite_border_rounded,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        17,
                        14,
                        17,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.brand != null &&
                              product.brand!.trim().isNotEmpty)
                            Text(
                              product.brand!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFF6600),
                              ),
                            ),

                          const SizedBox(height: 6),

                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 19,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF202938),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF202938),
                                ),
                              ),

                              const SizedBox(width: 10),

                              if (product.discount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF13A765),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '-${product.discount.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _buildStars(product.rating),

                              const SizedBox(width: 7),

                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF606775),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: inStock
                                  ? const Color(0xFFEAF8F1)
                                  : const Color(0xFFFFEEEE),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  inStock
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 15,
                                  color: inStock
                                      ? const Color(0xFF13A765)
                                      : const Color(0xFFFF3D3D),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  inStock
                                      ? 'In Stock (${product.quantity} available)'
                                      : 'Out of Stock',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: inStock
                                        ? const Color(0xFF13A765)
                                        : const Color(0xFFFF3D3D),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF202938),
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            product.description?.trim().isNotEmpty == true
                                ? product.description!
                                : 'No description available for this product.',
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.55,
                              color: Color(0xFF6D7480),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: const [
                              Expanded(
                                child: _FeatureCard(
                                  icon: Icons.verified_outlined,
                                  title: 'Certified Safe',
                                  subtitle: 'Baby approved',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _FeatureCard(
                                  icon: Icons.local_shipping_outlined,
                                  title: 'Free Delivery',
                                  subtitle: 'On eligible orders',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _FeatureCard(
                                  icon: Icons.workspace_premium_outlined,
                                  title: 'Top Brand',
                                  subtitle: 'Trusted quality',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF202938),
                                ),
                              ),

                              Row(
                                children: [
                                  _quantityButton(
                                    icon: Icons.remove,
                                    onTap: _quantity > 1
                                        ? () {
                                            setState(() {
                                              _quantity--;
                                            });
                                          }
                                        : null,
                                  ),

                                  SizedBox(
                                    width: 38,
                                    child: Center(
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF202938),
                                        ),
                                      ),
                                    ),
                                  ),

                                  _quantityButton(
                                    icon: Icons.add,
                                    onTap: inStock &&
                                            _quantity < product.quantity
                                        ? () {
                                            setState(() {
                                              _quantity++;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF202938),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const _ReviewCard(
                            name: 'Customer',
                            rating: 5,
                            review:
                                'Great product. The quality is excellent and exactly as expected.',
                          ),

                          const SizedBox(height: 8),

                          const _ReviewCard(
                            name: 'Verified Buyer',
                            rating: 5,
                            review:
                                'Very happy with this purchase. Would definitely recommend it.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(
                17,
                10,
                17,
                14,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: inStock ? () {} : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(
                          color: inStock
                              ? const Color(0xFFFF6600)
                              : const Color(0xFFCCCCCC),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: inStock
                              ? const Color(0xFFFF6600)
                              : const Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: inStock ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: const Color(0xFFFF6600),
                        disabledBackgroundColor: const Color(0xFFCCCCCC),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_loadingImage) {
      return Container(
        color: const Color(0xFFF7F7F7),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_image != null && _image!.isNotEmpty) {
      return Image.memory(
        _image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF7F7F7),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 50,
          color: Color(0xFFB5BAC3),
        ),
      ),
    );
  }

  Widget _topButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 19,
          color: const Color(0xFF273143),
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFF3F4F6)
              : const Color(0xFFE5E6E8),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 15,
          color: onTap != null
              ? const Color(0xFF273143)
              : const Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    final int fullStars = rating.floor().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Text(
          index < fullStars ? '★' : '☆',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFFFFB000),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFFFF6600),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Color(0xFF273143),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 7,
              color: Color(0xFF969CA7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final double rating;
  final String review;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF273143),
                ),
              ),
              const Spacer(),
              Text(
                '★★★★★',
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFFFFB000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            review,
            style: const TextStyle(
              fontSize: 9,
              height: 1.4,
              color: Color(0xFF707784),
            ),
          ),
        ],
      ),
    );
  }
}