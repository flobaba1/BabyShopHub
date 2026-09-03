import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../screens/app/products/product_details.dart';
import '../models/product.dart';
import '../../../core/mysql_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Uint8List? _productImage;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadProductImage();
  }

  Future<void> _loadProductImage() async {
    try {
      final image = await MySQLService().getProductImage(widget.product.id);

      if (!mounted) return;

      setState(() {
        _productImage = image;
        _isLoadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _productImage = null;
        _isLoadingImage = false;
      });

      debugPrint(
        'Failed to load image for product ${widget.product.id}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProductDetailsScreen(product: product);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE8E5E2),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //product image

            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 107,
                  child: _buildProductImage(),
                ),

               //product badge

                if (product.badge != null &&
                    product.badge!.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(product.badge!),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

               //favourite button

                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      // Favourite functionality can be connected
                      // to your wishlist/MySQLService later.
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 14,
                        color: Color(0xFF7F8794),
                      ),
                    ),
                  ),
                ),

                //discount

                if (product.discount > 0)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13A765),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '-${product.discount.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            //product information

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 7, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //brand

                  if (product.brand != null &&
                      product.brand!.isNotEmpty)
                    Text(
                      product.brand!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF6600),
                      ),
                    ),

                  const SizedBox(height: 3),

                //product name

                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      height: 1.18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF273143),
                    ),
                  ),

                  const SizedBox(height: 4),

                  //rating

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _buildStars(product.rating),
                        style: const TextStyle(
                          fontSize: 7.5,
                          letterSpacing: 0.5,
                          color: Color(0xFFFFB000),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 7,
                          color: Color(0xFF9BA1AE),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                 //price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202938),
                        ),
                      ),

                      const Spacer(),

                      //add button

                      GestureDetector(
                        onTap: () {
                          // Add-to-cart functionality can be connected
                          // to your MySQLService later.
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6600),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 //product image

  Widget _buildProductImage() {
    if (_isLoadingImage) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_productImage == null || _productImage!.isEmpty) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 35,
            color: Color(0xFFB0B0B0),
          ),
        ),
      );
    }

    return Image.memory(
      _productImage!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 35,
              color: Color(0xFFB0B0B0),
            ),
          ),
        );
      },
    );
  }

  //rating stars

  String _buildStars(double rating) {
    final int fullStars = rating.floor().clamp(0, 5);
    final int emptyStars = 5 - fullStars;

    return '${'★' * fullStars}${'☆' * emptyStars}';
  }

  //badge color

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'organic':
        return const Color(0xFF13A765);

      case 'sale':
        return const Color(0xFFFF3D3D);

      case 'new':
        return const Color(0xFF3685E8);

      case 'top rated':
      case 'best seller':
        return const Color(0xFFFF6600);

      case 'featured':
        return const Color(0xFF8E5BEF);

      default:
        return const Color(0xFFFF6600);
    }
  }
}