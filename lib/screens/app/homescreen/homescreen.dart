import 'package:flutter/material.dart';

import '../../../utilities/models/product.dart';
import '../../../core/mysql_service.dart';
import '../../../utilities/widgets/product_card.dart';
import '../products/all_products.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

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
                                color: Color(0xFF8C929C),
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

                      _circleButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                      ),

                      const SizedBox(width: 8),

                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFE3D2),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllProductsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE7E8EA)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 21,
                            color: Color(0xFF9298A3),
                          ),
                          SizedBox(width: 9),
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
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/banner.jpg',
                      width: double.infinity,
                      height: 145,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 145,
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
                  ),

                  const SizedBox(height: 20),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllProductsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 84,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _CategoryItem(
                          icon: Icons.baby_changing_station_outlined,
                          name: 'Diapers',
                        ),
                        _CategoryItem(
                          icon: Icons.restaurant_outlined,
                          name: 'Baby Food',
                        ),
                        _CategoryItem(
                          icon: Icons.checkroom_outlined,
                          name: 'Clothing',
                        ),
                        _CategoryItem(icon: Icons.toys_outlined, name: 'Toys'),
                        _CategoryItem(
                          icon: Icons.bathtub_outlined,
                          name: 'Bath & Care',
                        ),
                        _CategoryItem(
                          icon: Icons.local_drink_outlined,
                          name: 'Feeding',
                        ),
                        _CategoryItem(
                          icon: Icons.child_friendly_outlined,
                          name: 'Accessories',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flash Deals',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF202938),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Limited time offers',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF858B95),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6600),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Text(
                            '02 : 18 : 42',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllProductsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (_isLoading)
                    const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
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

                  const SizedBox(height: 20),

                  Row(
                    children: const [
                      Expanded(
                        child: _BenefitCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Fast Delivery',
                          subtitle: 'Quick & reliable',
                        ),
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: _BenefitCard(
                          icon: Icons.verified_outlined,
                          title: 'Safe Products',
                          subtitle: 'Quality guaranteed',
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
          TextButton(onPressed: _loadProducts, child: const Text('Try Again')),
        ],
      ),
    );
  }

  static Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Icon(icon, size: 19, color: const Color(0xFF4C5360)),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String name;

  const _CategoryItem({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFFFF6600), size: 25),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555C68),
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 21, color: const Color(0xFFFF6600)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF273143),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 7, color: Color(0xFF979DA7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
