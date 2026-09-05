import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../screens/app/products/product_details.dart';
import '../models/product.dart';
import '../../core/mysql_service.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(product: product),

            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BRAND
                  if (product.brand != null && product.brand!.trim().isNotEmpty)
                    Text(
                      product.brand!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF6600),
                      ),
                    ),

                  if (product.brand != null && product.brand!.trim().isNotEmpty)
                    const SizedBox(height: 3),

                  // PRODUCT NAME
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF273143),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // RATING
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Color(0xFFFFB000),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6E7480),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // PRICE + ADD BUTTON
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF202938),
                          ),
                        ),
                      ),

                      Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6600),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // STOCK
                  Text(
                    product.quantity > 0
                        ? '${product.quantity} in stock'
                        : 'Out of stock',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w500,
                      color: product.quantity > 0
                          ? const Color(0xFF13A765)
                          : const Color(0xFFFF3D3D),
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

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(2)}';
  }
}

// ============================================================
// PRODUCT IMAGE
// ============================================================

class _ProductImage extends StatelessWidget {
  final Product product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 125,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List?>(
            future: MySQLService().getProductImage(product.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: const Color(0xFFF6F6F6),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFF6600),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return Container(
                  color: const Color(0xFFF6F6F6),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 35,
                      color: Color(0xFFB8BDC6),
                    ),
                  ),
                );
              }

              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              );
            },
          ),

          // BADGE
          if (product.badge != null && product.badge!.trim().isNotEmpty)
            Positioned(
              top: 7,
              left: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor(product.badge!),
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

          // DISCOUNT
          if (product.discount > 0)
            Positioned(
              right: 7,
              bottom: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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

          // FAVORITE
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 15,
                color: Color(0xFF7F8794),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String badge) {
    final value = badge.toLowerCase();

    if (value.contains('new')) {
      return const Color(0xFF3685E8);
    }

    if (value.contains('sale') || value.contains('hot')) {
      return const Color(0xFFFF3D3D);
    }

    if (value.contains('best')) {
      return const Color(0xFF8E5BEF);
    }

    return const Color(0xFFFF6600);
  }
}
