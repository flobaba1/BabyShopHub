import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';
import '../../../utilities/widgets/product_card.dart';
import '../products/all_products.dart';
import '../categories/categories.dart';
import '../categories/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MySQLService _mysqlService = MySQLService();

  List<Product> _products = [];

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _categories = [];
  bool _isCategoriesLoading = true;
  String? _categoriesError;

  @override
  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _mysqlService.fetchProductsPaginated(
        offset: 0,
        limit: 20,
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

  Future<void> _loadCategories() async {
    try {
      final categories = await _mysqlService.getCategoriesWithProductCount();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
        _categoriesError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCategoriesLoading = false;
        _categoriesError = e.toString();
      });
    }
  }

  //build home categories
  Widget _buildHomeCategories() {
    if (_isCategoriesLoading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFF6600),
          ),
        ),
      );
    }

    if (_categoriesError != null) {
      return GestureDetector(
        onTap: _loadCategories,
        child: const Center(
          child: Text(
            'Unable to load categories. Tap to retry.',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFFF6600),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories found.',
          style: TextStyle(fontSize: 10, color: Color(0xFF888E98)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((category) {
          final String categoryId = category['id']?.toString() ?? '';

          final String categoryName = category['name']?.toString() ?? '';

          return _CategoryItem(
            icon: _getCategoryIcon(categoryName),
            name: categoryName,
            backgroundColor: _getCategoryBackgroundColor(categoryName),
            iconColor: _getCategoryIconColor(categoryName),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProductsScreen(
                    categoryId: categoryId,
                    categoryName: categoryName,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  //get category icon based on name
  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'Diapers':
        return Icons.baby_changing_station_rounded;

      case 'Baby Food':
        return Icons.restaurant_rounded;

      case 'Clothing':
        return Icons.checkroom_rounded;

      case 'Toys':
        return Icons.toys_rounded;

      case 'Bath & Care':
        return Icons.bathtub_rounded;

      case 'Feeding':
        return Icons.local_drink_rounded;

      case 'Accessories':
        return Icons.child_friendly_rounded;

      default:
        return Icons.category_rounded;
    }
  }

  //get category background color based on name
  Color _getCategoryBackgroundColor(String name) {
    switch (name) {
      case 'Diapers':
        return const Color(0xFFFFE5D7);

      case 'Baby Food':
        return const Color(0xFFE0F5E5);

      case 'Clothing':
        return const Color(0xFFDCE8FF);

      case 'Toys':
        return const Color(0xFFFFF0D1);

      case 'Bath & Care':
        return const Color(0xFFEEDFFF);

      case 'Feeding':
        return const Color(0xFFDDF6F7);

      case 'Accessories':
        return const Color(0xFFFFE0EC);

      default:
        return const Color(0xFFF2F2F2);
    }
  }

  //get category icon color based on name
  Color _getCategoryIconColor(String name) {
    switch (name) {
      case 'Diapers':
        return const Color(0xFFFF8A4C);

      case 'Baby Food':
        return const Color(0xFF3FA65B);

      case 'Clothing':
        return const Color(0xFF5C83D6);

      case 'Toys':
        return const Color(0xFFD89B31);

      case 'Bath & Care':
        return const Color(0xFF9A64D6);

      case 'Feeding':
        return const Color(0xFF42A5A9);

      case 'Accessories':
        return const Color(0xFFD95C87);

      default:
        return const Color(0xFF777777);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 240, 206),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF6600),
          onRefresh: _loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // =========================================================
                  // HEADER
                  // =========================================================
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good afternoon,',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF858A94),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'New 👋',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF202938),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notification
                      _circleButton(
                        icon: Icons.notifications_none_rounded,
                        showDot: true,
                        onTap: () {},
                      ),

                      const SizedBox(width: 9),

                      // Profile
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF6600),
                        ),
                        child: const Center(
                          child: Text(
                            'N',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 17),

                  // =========================================================
                  // SEARCH BAR
                  // =========================================================
                  GestureDetector(
                    onTap: () {
                      context.push('/products');
                    },
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.only(left: 13, right: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: const Color(0xFFEDE5DF)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFFFF6600),
                          ),

                          const SizedBox(width: 9),

                          const Expanded(
                            child: Text(
                              'Search diapers, toys, food...',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9AA0AA),
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFF6600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // =========================================================
                  // PROMOTIONAL BANNER
                  // =========================================================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: SizedBox(
                      width: double.infinity,
                      height: 132,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/banner.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFFFE3D2),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Color(0xFFFF6600),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Dark/light gradient for text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.38),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            left: 17,
                            top: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.88),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'LIMITED TIME OFFER',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7B4B35),
                                ),
                              ),
                            ),
                          ),

                          const Positioned(
                            left: 17,
                            top: 42,
                            child: Text(
                              'Up to 30% OFF',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const Positioned(
                            left: 17,
                            top: 68,
                            child: Text(
                              'On all baby essentials this week',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Positioned(
                            left: 17,
                            bottom: 14,
                            child: GestureDetector(
                              onTap: () {
                                context.push('/products');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Shop Now',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFFF6600),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 12,
                                      color: Color(0xFFFF6600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            right: 12,
                            top: 11,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.88),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: Color(0xFF6E727A),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    '2d 14h left',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6E727A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 17),

                  // =========================================================
                  // CATEGORIES HEADER
                  // =========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202938),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          context.go('/categories');
                        },
                        child: const Text(
                          'See All →',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // =========================================================
                  // CATEGORIES
                  // =========================================================
                  SizedBox(height: 82, child: _buildHomeCategories()),

                  const SizedBox(height: 18),

                  // =========================================================
                  // FLASH DEALS
                  // =========================================================
                  Container(
                    width: double.infinity,
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6A00), Color(0xFFFF9900)],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 19,
                        ),

                        const SizedBox(width: 5),

                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flash Deals',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Ends in 06:24:51',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _TimeBox(text: '06'),
                        const SizedBox(width: 5),
                        _TimeBox(text: '24'),
                        const SizedBox(width: 5),
                        _TimeBox(text: '51'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================================================
                  // FEATURED PRODUCTS HEADER
                  // =========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Products',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202938),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          context.push('/products');
                        },
                        child: const Text(
                          'See All →',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // =========================================================
                  // PRODUCTS
                  //
                  // DO NOT CHANGE THIS SECTION.
                  // ProductCard functionality remains untouched.
                  // =========================================================
                  if (_isLoading)
                    const SizedBox(
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6600),
                        ),
                      ),
                    )
                  else if (_error != null)
                    _buildError()
                  else if (_products.isEmpty)
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No products found.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888E98),
                          ),
                        ),
                      ),
                    )
                  else
                    _productColumns(),

                  const SizedBox(height: 12),

                  // =========================================================
                  // BENEFITS
                  // =========================================================
                  Row(
                    children: const [
                      Expanded(
                        child: _BenefitCard(
                          icon: Icons.verified_user_outlined,
                          title: '100% Safe',
                          subtitle: 'Certified products',
                        ),
                      ),

                      SizedBox(width: 7),

                      Expanded(
                        child: _BenefitCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Fast Delivery',
                          subtitle: 'Same day',
                        ),
                      ),

                      SizedBox(width: 7),

                      Expanded(
                        child: _BenefitCard(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Top Brands',
                          subtitle: 'Trusted quality',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // EXISTING PRODUCT FUNCTIONALITY
  // ===========================================================

  Widget _productColumns() {
    final products = _products.take(6).toList();

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

        const SizedBox(width: 10),

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

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 35,
            color: Color(0xFFFF6600),
          ),

          const SizedBox(height: 8),

          const Text(
            'Unable to load products',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: _loadProducts,
            child: const Text(
              'Try Again',
              style: TextStyle(color: Color(0xFFFF6600)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8E8E8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF4C5360)),
          ),

          if (showDot)
            Positioned(
              right: 7,
              top: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6600),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===============================================================
// CATEGORY ITEM
// ===============================================================

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CategoryItem({
    required this.icon,
    required this.name,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 9),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 23),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555C68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// FLASH DEAL TIME BOX
// ===============================================================

class _TimeBox extends StatelessWidget {
  final String text;

  const _TimeBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ===============================================================
// BENEFIT CARD
// ===============================================================

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFEDE8E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFFF6600)),

          const SizedBox(height: 3),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Color(0xFF273143),
            ),
          ),

          const SizedBox(height: 1),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 6.5, color: Color(0xFF979DA7)),
          ),
        ],
      ),
    );
  }
}
