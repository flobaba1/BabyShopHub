import 'package:flutter/material.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final MySQLService _mysqlService = MySQLService();

  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  // ---------------------------------------------------------------------------
  // CATEGORY DESIGN DATA
  // ---------------------------------------------------------------------------

  static const Map<String, IconData> categoryIcons = {
    'Diapers': Icons.baby_changing_station,
    'Baby Food': Icons.restaurant,
    'Clothing': Icons.checkroom,
    'Toys': Icons.toys,
    'Bath & Care': Icons.bathtub,
    'Feeding': Icons.child_friendly,
    'Accessories': Icons.backpack,
  };

  static const Map<String, Color> categoryColors = {
    'Diapers': Color(0xFFFEECE2),
    'Baby Food': Color(0xFFE1F4E5),
    'Clothing': Color(0xFFE1ECFD),
    'Toys': Color(0xFFFFF7E2),
    'Bath & Care': Color(0xFFEFE2FE),
    'Feeding': Color(0xFFE1F5FE),
    'Accessories': Color(0xFFFEE2EC),
  };

  static const List<String> popularSearches = [
    'Huggies',
    'Organic formula',
    'Baby monitor',
    'Teether',
    'Swaddle',
    'Night cream',
    'Bottles',
    'Baby gym',
  ];

  @override
  void initState() {
    super.initState();

    _categoriesFuture = _mysqlService.getCategoriesWithProductCount();
  }

  // ---------------------------------------------------------------------------
  // REFRESH CATEGORIES
  // ---------------------------------------------------------------------------

  Future<void> _refreshCategories() async {
    setState(() {
      _categoriesFuture = _mysqlService.getCategoriesWithProductCount();
    });

    await _categoriesFuture;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCategories,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Categories',

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D2338),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Browse by product type',

                  style: TextStyle(fontSize: 15, color: Color(0xFF7F848F)),
                ),

                const SizedBox(height: 24),

                // ----------------------------------------------------------------
                // CATEGORIES FROM MYSQL
                // ----------------------------------------------------------------
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _categoriesFuture,

                  builder: (context, snapshot) {
                    // ------------------------------------------------------------
                    // LOADING
                    // ------------------------------------------------------------

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),

                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // ------------------------------------------------------------
                    // ERROR
                    // ------------------------------------------------------------

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),

                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 45,
                                color: Colors.redAccent,
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Unable to load categories',

                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D2338),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                '${snapshot.error}',

                                textAlign: TextAlign.center,

                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7F848F),
                                ),
                              ),

                              const SizedBox(height: 16),

                              ElevatedButton(
                                onPressed: _refreshCategories,

                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // ------------------------------------------------------------
                    // EMPTY
                    // ------------------------------------------------------------

                    final categories = snapshot.data ?? [];

                    if (categories.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),

                          child: Text(
                            'No categories found.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF7F848F),
                            ),
                          ),
                        ),
                      );
                    }

                    // ------------------------------------------------------------
                    // CATEGORY GRID
                    // ------------------------------------------------------------

                    return GridView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: categories.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,

                            crossAxisSpacing: 14,

                            mainAxisSpacing: 14,

                            childAspectRatio: 1.30,
                          ),

                      itemBuilder: (context, index) {
                        final category = categories[index];

                        final String name = category['name']?.toString() ?? '';

                        final int count = category['count'] is int
                            ? category['count']
                            : int.tryParse(
                                    category['count']?.toString() ?? '0',
                                  ) ??
                                  0;

                        final IconData icon =
                            categoryIcons[name] ?? Icons.category;

                        final Color backgroundColor =
                            categoryColors[name] ?? const Color(0xFFF2F2F2);

                        return _CategoryCard(
  name: name,
  count: '$count products',
  icon: icon,
  backgroundColor: backgroundColor,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(
          categoryId: category['id'].toString(),
          categoryName: name,
        ),
      ),
    );
  },
);
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                // ----------------------------------------------------------------
                // POPULAR SEARCHES
                // ----------------------------------------------------------------
                const Text(
                  'Popular Searches',

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D2338),
                  ),
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: popularSearches.map((search) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 9,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),

                      child: Text(
                        search,

                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111625),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// CATEGORY CARD
// ===========================================================================

class _CategoryCard extends StatelessWidget {
  final String name;
  final String count;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.name,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: backgroundColor,

          borderRadius: BorderRadius.circular(16),
        ),

        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Icon(icon, size: 32, color: const Color(0xFF1D2338)),

                const SizedBox(height: 10),

                Text(
                  name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,

                    fontWeight: FontWeight.w600,

                    color: Color(0xFF111625),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  count,

                  style: const TextStyle(
                    fontSize: 13,

                    color: Color(0xFF637085),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 0,

              right: 0,

              child: Container(
                width: 28,

                height: 28,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.chevron_right,

                  size: 20,

                  color: Color(0xFF1D2338),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
