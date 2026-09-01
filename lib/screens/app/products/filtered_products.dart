import 'package:flutter/material.dart';
import '../../../utilities/models/product.dart';
import '../../../utilities/widgets/product_card.dart';

class FilteredProductsScreen extends StatelessWidget {
  const FilteredProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 66,
              color: const Color(0xFFFFF9F5),
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Row(
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        'All Products',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202938),
                        ),
                      ),
                    ),
                  ),

                  _circleButton(icon: Icons.tune_rounded, onTap: () {}),
                ],
              ),
            ),

            //search
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 12, 19, 9),
              child: Container(
                height: 31,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFFFE5D2)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),

                    const Icon(
                      Icons.search_rounded,
                      size: 14,
                      color: Color(0xFFFF6600),
                    ),

                    const SizedBox(width: 7),

                    const Text(
                      'Search in All Products...',
                      style: TextStyle(fontSize: 8, color: Color(0xFF9BA3B1)),
                    ),
                  ],
                ),
              ),
            ),

            // sort box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFE9E3DD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF30394A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _sortChip('Featured', selected: true),

                        _sortChip('Price: Low'),

                        _sortChip('Price: High'),

                        _sortChip('Top Rated'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            //product count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Row(
                children: [
                  Text(
                    '${products.length} products found',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF6D7482),
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6600),
                    ),
                  ),

                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 12,
                    color: Color(0xFFFF6600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 7),

            //products
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: _productColumns(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //product columns

  Widget _productColumns() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < products.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(product: products[i]),
                ),
            ],
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i < products.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(product: products[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  //sort chip

  Widget _sortChip(String text, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFF6600) : const Color(0xFFFFF8F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : const Color(0xFF4E5868),
        ),
      ),
    );
  }

  //header icon

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8E1DB)),
        ),
        child: Center(
          child: Icon(icon, size: 12, color: const Color(0xFF697384)),
        ),
      ),
    );
  }
}
