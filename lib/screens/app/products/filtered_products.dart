import 'package:flutter/material.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';
import '../../../utilities/widgets/product_card.dart';

class FilteredProductsScreen extends StatefulWidget {
  const FilteredProductsScreen({
    super.key,
  });

  @override
  State<FilteredProductsScreen> createState() =>
      _FilteredProductsScreenState();
}

class _FilteredProductsScreenState
    extends State<FilteredProductsScreen> {
  final MySQLService _mysqlService = MySQLService();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'Featured';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products =
          await _mysqlService.fetchProductsPaginated(
        offset: 0,
        limit: 50,
      );

      if (!mounted) return;

      setState(() {
        _allProducts = products;
        _filteredProducts = List.from(products);
        _isLoading = false;
      });

      _applyFilter();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _applyFilter() {
    final products = List<Product>.from(_allProducts);

    switch (_selectedFilter) {
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
        // Keep database order.
        break;
    }

    setState(() {
      _filteredProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF273143),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Filter Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF273143),
          ),
        ),

        centerTitle: true,
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6600),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 45,
                color: Color(0xFFB0B5BE),
              ),
              const SizedBox(height: 15),
              const Text(
                'Unable to load products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _loadProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6600),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // FILTER OPTIONS
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(
            14,
            14,
            14,
            14,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Featured'),
                _filterChip('Price: Low'),
                _filterChip('Price: High'),
                _filterChip('Top Rated'),
              ],
            ),
          ),
        ),

        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(
                      color: Color(0xFF7E8591),
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    14,
                    12,
                    20,
                  ),
                  itemCount: _filteredProducts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.70,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: _filteredProducts[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String title) {
    final bool selected = _selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });

        _applyFilter();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF6600)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF6600)
                : const Color(0xFFE2E2E2),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : const Color(0xFF555D6B),
          ),
        ),
      ),
    );
  }
}