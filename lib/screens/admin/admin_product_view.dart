import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'add_product_view.dart';
import 'package:baby_shop_hub/utilities/models/product.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';

class AdminProductsView extends StatefulWidget {
  const AdminProductsView({super.key});

  @override
  State<AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<AdminProductsView> {
  final MySQLService _dbService = MySQLService();

  int _currentPage = 1;
  final int _pageSize = 20;

  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  final Map<String, Future<Uint8List?>> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<Uint8List?> _getProductImage(String productId) {
    // If this product image has already been requested,
    // return the existing Future.
    if (_imageCache.containsKey(productId)) {
      return _imageCache[productId]!;
    }

    // Create the request only once.
    final future = _dbService.getProductImage(productId);

    // Save the Future immediately.
    _imageCache[productId] = future;

    // If the request fails, remove it from the cache so that
    // a future attempt can try again.
    future.catchError((error) {
      _imageCache.remove(productId);
      return null;
    });

    return future;
  }

  // ------------------------------------------------------------
  // LOAD PRODUCTS
  // ------------------------------------------------------------
  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final offset = (_currentPage - 1) * _pageSize;

      final products = await _dbService.fetchProductsPaginated(
        offset: offset,
        limit: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _products = products;
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

  // ------------------------------------------------------------
  // DELETE PRODUCT
  // ------------------------------------------------------------
  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _dbService.deleteProduct(productId);

      if (success && mounted) {
        // Remove the deleted product's image from cache.
        _imageCache.remove(productId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );

        await _loadProducts();
      }
    }
  }

  // ------------------------------------------------------------
  // ADD PRODUCT
  // ------------------------------------------------------------
  Future<void> _navigateAndAddProduct() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    if (updated == true && mounted) {
      await _loadProducts();
    }
  }

  // ------------------------------------------------------------
  // EDIT PRODUCT
  // ------------------------------------------------------------
  Future<void> _navigateAndEditProduct(Product product) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(productToEdit: product),
      ),
    );

    if (updated == true && mounted) {
      _imageCache.remove(product.id);

      await _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateAndAddProduct,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Add New',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Color(0xFFFF5722)),
              ),
            )
          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading products:\n$_error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          // ------------------------------------------------------
          // EMPTY
          // ------------------------------------------------------
          else if (_products.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No products found'),
              ),
            )
          // ------------------------------------------------------
          // PRODUCTS
          // ------------------------------------------------------
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = _products[index];

                return ProductItemCard(
                  key: ValueKey(product.id),
                  product: product,

                  // IMPORTANT:
                  // The card receives the cached Future.
                  //
                  // It does NOT create a new MySQLService.
                  imageFuture: _getProductImage(product.id),

                  onEdit: () => _navigateAndEditProduct(product),
                  onDelete: () => _deleteProduct(product.id),
                );
              },
            ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // PAGINATION
          // ------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });

                        _loadProducts();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                label: const Text('Previous'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5722),
                  disabledForegroundColor: Colors.grey,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Page $_currentPage',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),

              TextButton.icon(
                onPressed: _products.length < _pageSize
                    ? null
                    : () {
                        setState(() {
                          _currentPage++;
                        });

                        _loadProducts();
                      },
                icon: const Text('Next'),
                label: const Icon(Icons.chevron_right_rounded, size: 20),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5722),
                  disabledForegroundColor: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================================
// PRODUCT ITEM CARD
// ============================================================================

class ProductItemCard extends StatefulWidget {
  final Product product;

  final Future<Uint8List?> imageFuture;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.imageFuture,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();

    // Save the Future once when this card is created.
    _imageFuture = widget.imageFuture;
  }

  @override
  void didUpdateWidget(covariant ProductItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the image Future changes, update it.
    if (oldWidget.imageFuture != widget.imageFuture) {
      _imageFuture = widget.imageFuture;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // PRODUCT IMAGE
          // ------------------------------------------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 60,
              color: const Color(0xFFF3F4F6),
              child: FutureBuilder<Uint8List?>(
                future: _imageFuture,
                builder: (context, snapshot) {
                  // IMAGE LOADING
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                    );
                  }

                  // IMAGE ERROR
                  if (snapshot.hasError) {
                    return const Icon(
                      Icons.broken_image_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 28,
                    );
                  }

                  final imageBytes = snapshot.data;

                  // NO IMAGE
                  if (imageBytes == null || imageBytes.isEmpty) {
                    return const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 28,
                    );
                  }

                  // IMAGE
                  return Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,

                    cacheWidth: 120,
                    cacheHeight: 120,

                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFF9CA3AF),
                        size: 28,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------------
          // PRODUCT INFORMATION
          // ------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.product.brand ?? 'Unbranded',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF5722),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'Stock: ${widget.product.quantity}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // ACTION BUTTONS
          // ------------------------------------------------------
          Column(
            children: [
              // EDIT
              InkWell(
                onTap: widget.onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // DELETE
              InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
