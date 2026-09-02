import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'add_product_view.dart';

// -----------------------------------------------------------------------------
// 1. PRODUCT MODEL (Supports both Asset/URL paths & Raw Byte arrays)
// -----------------------------------------------------------------------------
class AdminProduct {
  final String title;
  final String brand;
  final String price;
  final String stock;
  final String status;
  final String? imageUrl;
  final Uint8List? imageBytes; // Raw byte array ready for MySQL BLOB storage

  const AdminProduct({
    required this.title,
    required this.brand,
    required this.price,
    required this.stock,
    required this.status,
    this.imageUrl,
    this.imageBytes,
  });
}

// -----------------------------------------------------------------------------
// 2. ADMIN PRODUCTS VIEW (Main Screen with Product List)
// -----------------------------------------------------------------------------
class AdminProductsView extends StatefulWidget {
  const AdminProductsView({super.key});

  @override
  State<AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<AdminProductsView> {
  int _currentPage = 1;
  final int _totalPages = 5;

  // Mutable list to allow dynamic product additions and edits
  final List<AdminProduct> _products = [
    const AdminProduct(
      title: 'Huggies Little Snugglers Diapers',
      brand: 'Huggies',
      price: '\$24.99',
      stock: 'Stock: 142',
      status: 'In Stock',
      imageUrl: 'assets/pampers.png',
    ),
    const AdminProduct(
      title: 'Pampers Swaddlers Sensitive',
      brand: 'Pampers',
      price: '\$28.99',
      stock: 'Stock: 89',
      status: 'In Stock',
      imageUrl: 'assets/image_Sweater.png',
    ),
    const AdminProduct(
      title: 'Gerber Organic 1st Foods Baby Food',
      brand: 'Gerber',
      price: '\$8.99',
      stock: 'Stock: 230',
      status: 'In Stock',
      imageUrl: 'https://via.placeholder.com/80',
    ),
  ];

  // Method to open AddProductScreen and await the returned product object
  Future<void> _navigateAndAddProduct() async {
    final result = await Navigator.push<AdminProduct>(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    if (result != null) {
      setState(() {
        _products.insert(0, result); // Inserts new product at the top
      });
    }
  }

  // Method to edit an existing product in the list
  Future<void> _navigateAndEditProduct(int index) async {
    final updatedProduct = await Navigator.push<AdminProduct>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(productToEdit: _products[index]),
      ),
    );

    if (updatedProduct != null) {
      setState(() {
        _products[index] = updatedProduct; // Replaces item at index
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
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

          // Product Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ProductItemCard(
                product: _products[index],
                onEdit: () => _navigateAndEditProduct(index),
              );
            },
          ),

          const SizedBox(height: 20),

          // Pagination Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                label: const Text('Previous'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5722),
                  disabledForegroundColor: Colors.grey.shade400,
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
                  'Page $_currentPage of $_totalPages',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
                icon: const Text('Next'),
                label: const Icon(Icons.chevron_right_rounded, size: 20),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5722),
                  disabledForegroundColor: Colors.grey.shade400,
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

// -----------------------------------------------------------------------------
// 3. PRODUCT ITEM CARD (Renders Image from Bytes or Path)
// -----------------------------------------------------------------------------
class ProductItemCard extends StatelessWidget {
  final AdminProduct product;
  final VoidCallback onEdit;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.onEdit,
  });

  Widget _buildProductImage() {
    // 1. Check if raw image bytes are present
    if (product.imageBytes != null) {
      return Image.memory(product.imageBytes!, fit: BoxFit.cover);
    }

    // 2. Fallback to Asset image path if available
    if (product.imageUrl != null && product.imageUrl!.startsWith('assets/')) {
      return Image.asset(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
      );
    }

    // 3. Fallback placeholder icon
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(
      Icons.inventory_2_outlined,
      color: Color(0xFF9CA3AF),
      size: 28,
    );
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 60,
              color: const Color(0xFFF3F4F6),
              child: _buildProductImage(),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
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
                  product.brand,
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
                      product.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.stock,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.status,
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            children: [
              InkWell(
                onTap: onEdit,
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
              InkWell(
                onTap: () {},
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
