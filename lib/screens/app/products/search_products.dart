import 'package:flutter/material.dart';

import '../../../core/mysql_service.dart';
import '../../../utilities/models/product.dart';
import '../../../utilities/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MySQLService _mysqlService = MySQLService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Product> _allProducts = [];
  List<Product> _searchResults = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadProducts();
    _searchController.addListener(_searchProducts);

    // Make sure the search field gets focus when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  Future<void> _loadProducts() async {
  print('SEARCH: Starting product load...');

  try {
    
    final products = await _mysqlService.getProducts();

    print('SEARCH: Products loaded = ${products.length}');

    if (products.isNotEmpty) {
      print('SEARCH: First product = ${products.first.name}');
      print('SEARCH: Category = ${products.first.categoryName}');
      print('SEARCH: Description = ${products.first.description}');
    }

    if (!mounted) return;

    setState(() {
      _allProducts = products;
      _isLoading = false;
    });

    print('SEARCH: _allProducts length = ${_allProducts.length}');
  } catch (e, stackTrace) {
    print('SEARCH ERROR: $e');
    print(stackTrace);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
}

  void _searchProducts() {
    final query = _searchController.text.trim().toLowerCase();

    if (!mounted) return;

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = _allProducts.where((product) {
        final name = product.name.toLowerCase();
        final category = product.categoryName?.toLowerCase() ?? '';
        final categoryId = product.categoryId.toLowerCase();
        final description = product.description?.toLowerCase() ?? '';
        final brand = product.brand?.toLowerCase() ?? '';
        final badge = product.badge?.toLowerCase() ?? '';
        final productId = product.id.toLowerCase();

        return name.contains(query) ||
            category.contains(query) ||
            categoryId.contains(query) ||
            description.contains(query) ||
            brand.contains(query) ||
            badge.contains(query) ||
            productId.contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchProducts);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSearchText = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF3C6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF3C6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF202938),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Color(0xFF202938),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            // SEARCH FIELD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF858A94),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF858A94),
                  ),
                  suffixIcon: hasSearchText
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF858A94),
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // RESULTS
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !hasSearchText
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 55,
                            color: Color(0xFFB0B4BC),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Search for a product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF202938),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Start typing to see products',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF858A94),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202938),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.58,
                          ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _searchResults[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
