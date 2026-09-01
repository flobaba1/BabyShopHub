import 'package:flutter/material.dart';
import '../../../utilities/models/product.dart';
import '../../../utilities/widgets/product_card.dart';
import 'filtered_products.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

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

                  // FILTER BUTTON
                  _circleButton(
                    icon: Icons.tune_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FilteredProductsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

           //search

            Padding(
              padding: const EdgeInsets.fromLTRB(
                19,
                12,
                19,
                8,
              ),
              child: Container(
                height: 31,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: const Color(0xFFFFE5D2),
                  ),
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
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFF9BA3B1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //count

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 19,
              ),
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

                  const SizedBox(width: 3),

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 19,
                ),
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

        // LEFT COLUMN
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < products.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ProductCard(
                    product: products[i],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 9),

        // RIGHT COLUMN
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i < products.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ProductCard(
                    product: products[i],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  //header icons

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE8E1DB),
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 12,
            color: const Color(0xFF697384),
          ),
        ),
      ),
    );
  }
}