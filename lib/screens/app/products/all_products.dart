import 'package:flutter/material.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';
import '../../../utilities/widgets/product_card.dart';
import 'filtered_products.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final MySQLService _mysqlService = MySQLService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _mysqlService.fetchProductsPaginated(
        offset: 0,
        limit: 100,
      );

      if (!mounted) return;

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _searchProducts(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          final name = product.name.toLowerCase();
          final brand = product.brand?.toLowerCase() ?? '';

          return name.contains(query) || brand.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 14, 17, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),

                      const Expanded(
                        child: Center(
                          child: Text(
                            'All Products',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF202938),
                            ),
                          ),
                        ),
                      ),

                      _circleButton(
                        icon: Icons.tune_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const FilteredProductsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: const Color(0xFFE7E8EA),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF9298A3),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchProducts,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search products...',
                              hintStyle: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFA0A5AE),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 13),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filteredProducts.length} products found',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF8D939D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: Color(0xFFFF6600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to load products',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: _loadProducts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF888E98),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(17, 0, 17, 20),
        child: _productColumns(),
      ),
    );
  }

  Widget _productColumns() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < _filteredProducts.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(
                    product: _filteredProducts[i],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i < _filteredProducts.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(
                    product: _filteredProducts[i],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE7E8EA),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFF4C5360),
        ),
      ),
    );
  }
}