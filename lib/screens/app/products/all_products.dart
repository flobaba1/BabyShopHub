import 'package:flutter/material.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';
import '../../../utilities/widgets/product_card.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final MySQLService _mysqlService = MySQLService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _searchController.addListener(_searchProducts);
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _mysqlService.fetchProductsPaginated(
        offset: 0,
        limit: 50,
      );

      if (!mounted) return;

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _searchProducts() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
      });
      return;
    }

    setState(() {
      _filteredProducts = _products.where((product) {
        final name = product.name.toLowerCase();
        final brand = product.brand?.toLowerCase() ?? '';
        final categoryId = product.categoryId.toLowerCase();

        return name.contains(query) ||
            brand.contains(query) ||
            categoryId.contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchProducts);
    _searchController.dispose();
    super.dispose();
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
          'All Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF273143),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF6600),
        onRefresh: _loadProducts,
        child: _buildBody(),
      ),
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
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
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
                        color: Color(0xFF273143),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7E8591),
                      ),
                    ),
                    const SizedBox(height: 18),
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
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E5E5),
                ),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF273143),
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF7E8591),
                    size: 21,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 19,
                          color: Color(0xFF7E8591),
                        ),
                      );
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Product count
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              _searchController.text.isEmpty
                  ? '${_products.length} Products'
                  : '${_filteredProducts.length} Products found',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF273143),
              ),
            ),
          ),
        ),

        // No products
        if (_filteredProducts.isEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _searchController.text.isEmpty
                          ? Icons.inventory_2_outlined
                          : Icons.search_off_rounded,
                      size: 48,
                      color: const Color(0xFFB0B5BE),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _searchController.text.isEmpty
                          ? 'No products available'
                          : 'No products found',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF273143),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Try searching for a different product.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7E8591),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

        // Products grid
        if (_filteredProducts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ProductCard(
                    product: _filteredProducts[index],
                  );
                },
                childCount: _filteredProducts.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.58,
              ),
            ),
          ),
      ],
    );
  }
}

