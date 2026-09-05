import 'package:flutter/material.dart';

import 'package:baby_shop_hub/utilities/models/product.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/utilities/widgets/product_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends State<CategoryProductsScreen> {
  final MySQLService _mysqlService = MySQLService();

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();

    _productsFuture =
        _mysqlService.fetchProductsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1D2338),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Color(0xFF1D2338),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: FutureBuilder<List<Product>>(
        future: _productsFuture,

        builder: (context, snapshot) {
          // ----------------------------------------------------------
          // LOADING
          // ----------------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ----------------------------------------------------------
          // ERROR
          // ----------------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.redAccent,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Unable to load products',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D2338),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F848F),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _productsFuture =
                              _mysqlService
                                  .fetchProductsByCategory(
                            widget.categoryId,
                          );
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data ?? [];

          // ----------------------------------------------------------
          // NO PRODUCTS
          // ----------------------------------------------------------

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: Color(0xFFB0B5BE),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'No products in ${widget.categoryName}',
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                ],
              ),
            );
          }

          // ----------------------------------------------------------
          // PRODUCTS
          // ----------------------------------------------------------

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              30,
            ),

            itemCount: products.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,

              crossAxisSpacing: 14,

              mainAxisSpacing: 14,

              childAspectRatio: 0.68,
            ),

            itemBuilder: (context, index) {
              final product = products[index];

              return ProductCard(
                product: product,
              );
            },
          );
        },
      ),
    );
  }
}