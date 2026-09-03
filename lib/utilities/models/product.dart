import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../screens/app/products/product_details.dart';
import '../models/product.dart';
import '../../core/mysql_service.dart';

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
  final MySQLService _mysqlService = MySQLService();

  Uint8List? _image;
  bool _imageLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final image = await _mysqlService.getProductImage(widget.product.id);

      if (!mounted) return;

      setState(() {
        _image = image;
        _imageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _imageLoading = false;
      });
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
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 107,
                  child: _buildProductImage(),
                ),

                if (product.badge != null &&
                    product.badge!.trim().isNotEmpty)
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

                Positioned(
                  top: 6,
                  right: 6,
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

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 7, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null &&
                      product.brand!.trim().isNotEmpty)
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

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStars(product.rating),

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

                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: product.quantity > 0
                              ? const Color(0xFFFF6600)
                              : const Color(0xFFB5B8BE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 15,
                          color: Colors.white,
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

  Widget _buildProductImage() {
    if (_imageLoading) {
      return Container(
        color: const Color(0xFFF7F7F7),
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
          size: 32,
          color: Color(0xFFB5BAC3),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    final int fullStars = rating.floor().clamp(0, 5);
    final bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Text(
            '★',
            style: TextStyle(
              fontSize: 7.5,
              color: Color(0xFFFFB000),
            ),
          );
        }

        if (index == fullStars && hasHalfStar) {
          return const Text(
            '★',
            style: TextStyle(
              fontSize: 7.5,
              color: Color(0xFFFFB000),
            ),
          );
        }

        return const Text(
          '☆',
          style: TextStyle(
            fontSize: 7.5,
            color: Color(0xFFFFB000),
          ),
        );
      }),
    );
  }

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