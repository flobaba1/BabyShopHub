import 'package:flutter/material.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';
import '../../../utilities/widgets/product_card.dart';

class FilteredProductsScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const FilteredProductsScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<FilteredProductsScreen> createState() =>
      _FilteredProductsScreenState();
}

class _FilteredProductsScreenState
    extends State<FilteredProductsScreen> {
  final MySQLService _mysqlService = MySQLService();

  List<Product> _products = [];
  List<Product> _displayProducts = [];

  bool _isLoading = true;
  String? _error;

  String _selectedSort = 'Featured';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<Product> products;

      if (widget.categoryId != null &&
          widget.categoryId!.trim().isNotEmpty) {
        products = await _mysqlService.fetchProductsByCategory(
          widget.categoryId!,
        );
      } else {
        products = await _mysqlService.fetchProductsPaginated(
          offset: 0,
          limit: 100,
        );
      }

      if (!mounted) return;

      setState(() {
        _products = products;
        _displayProducts = List<Product>.from(products);
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

  void _sortProducts(String sort) {
    final products = List<Product>.from(_products);

    switch (sort) {
      case 'Price: Low':
        products.sort(
          (a, b) => a.price.compareTo(b.price),
        );
        break;

      case 'Price: High':
        products.sort(
          (a, b) => b.price.compareTo(a.price),
        );
        break;

      case 'Top Rated':
        products.sort(
          (a, b) => b.rating.compareTo(a.rating),
        );
        break;

      case 'Featured':
      default:
        products.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
        break;
    }

    setState(() {
      _selectedSort = sort;
      _displayProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName?.trim().isNotEmpty == true
        ? widget.categoryName!
        : 'All Products';

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

                      Expanded(
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF202938),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 36),
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
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF9298A3),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Search products...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFA0A5AE),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 13),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_displayProducts.length} products found',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF8D939D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _sortChip('Featured'),
                        const SizedBox(width: 7),
                        _sortChip('Price: Low'),
                        const SizedBox(width: 7),
                        _sortChip('Price: High'),
                        const SizedBox(width: 7),
                        _sortChip('Top Rated'),
                      ],
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

    if (_displayProducts.isEmpty) {
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
              for (int i = 0; i < _displayProducts.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(
                    product: _displayProducts[i],
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
              for (int i = 1; i < _displayProducts.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(
                    product: _displayProducts[i],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sortChip(String text) {
    final selected = _selectedSort == text;

    return GestureDetector(
      onTap: () => _sortProducts(text),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF6600)
              : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF6600)
                : const Color(0xFFE3E4E7),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: selected
                ? Colors.white
                : const Color(0xFF656B76),
          ),
        ),
      ),
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