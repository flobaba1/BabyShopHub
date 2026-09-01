import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;

    switch (product.badgeColor) {
      case 'green':
        badgeColor = const Color(0xFF19A95A);
        break;

      case 'red':
        badgeColor = const Color(0xFFFF3D3D);
        break;

      case 'blue':
        badgeColor = const Color(0xFF3685E8);
        break;

      default:
        badgeColor = const Color(0xFFFF6600);
    }

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7E3DF)),
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
                child: Image.asset(product.image, fit: BoxFit.cover),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    product.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
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
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 14,
                    color: Color(0xFF7A8190),
                  ),
                ),
              ),
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
                    product.discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
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
                Text(
                  product.brand,
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
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF273143),
                  ),
                ),

                const SizedBox(height: 4),

                // =================================================
                // RATING
                // =================================================
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.rating,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFFFFB000),
                      ),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '(${product.reviews})',
                      style: const TextStyle(
                        fontSize: 7,
                        color: Color(0xFF9BA1AE),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // =================================================
                // PRICE + ADD BUTTON
                // =================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Current price
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF202938),
                      ),
                    ),

                    const SizedBox(width: 5),

                    // Old price
                    Flexible(
                      child: Text(
                        product.oldPrice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 7.5,
                          color: Color(0xFFA4A9B2),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Add button
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6600),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
