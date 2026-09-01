import 'package:flutter/material.dart';
import '../../../utilities/models/product.dart';
import '../../../utilities/widgets/product_card.dart';
import '../products/all_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // =====================================================
                // TOP GREETING SECTION
                // =====================================================
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good afternoon,',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF687386),
                            ),
                          ),

                          SizedBox(height: 2),

                          Text(
                            'New 👋',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF182235),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: const Color(0xFFE8E3DE)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: Color(0xFF536071),
                            ),
                          ),

                          Positioned(
                            top: 6,
                            right: 7,
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor: Color(0xFFFF6600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 9),

                    // Profile
                    Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6600),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                // =====================================================
                // SEARCH BAR
                // =====================================================
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllProductsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E3DE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),

                        const Icon(
                          Icons.search_rounded,
                          size: 17,
                          color: Color(0xFFFF6600),
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Text(
                            'Search diapers, toys, food...',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF9BA3B1),
                            ),
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1E5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // =====================================================
                // PROMOTIONAL BANNER
                // =====================================================
                Container(
                  height: 132,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: const DecorationImage(
                      image: AssetImage('assets/banner.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(17, 13, 10, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xAA663D28), Color(0x22000000)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LIMITED TIME OFFER',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              '◷ 2d 14h left',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'Up to 30% OFF',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 2),

                        const Text(
                          'On all baby essentials this week',
                          style: TextStyle(fontSize: 9, color: Colors.white),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Shop Now →',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF6600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================================
                // CATEGORIES
                // =====================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF182235),
                      ),
                    ),

                    const Text(
                      'See All →',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Horizontally scrollable categories
                SizedBox(
                  height: 68,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _category('🍼', 'Diapers', const Color(0xFFFFE9D9)),

                      _category('🥕', 'Baby Food', const Color(0xFFDDF4DF)),

                      _category('👕', 'Clothing', const Color(0xFFDDE9FF)),

                      _category('🧸', 'Toys', const Color(0xFFFFF0CC)),

                      _category('🛁', 'Bath & Care', const Color(0xFFEEDCFF)),

                      _category('🍽️', 'Feeding', const Color(0xFFDDF3F5)),

                      _category('👜', 'Accessories', const Color(0xFFFFE0EF)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // =====================================================
                // FLASH DEALS
                // =====================================================
                Container(
                  height: 51,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6600), Color(0xFFFFA000)],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 17,
                      ),

                      const SizedBox(width: 5),

                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flash Deals',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          Text(
                            'Ends in 06:24:51',
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ],
                      ),

                      const Spacer(),

                      _timerBox('06'),
                      const SizedBox(width: 5),
                      _timerBox('24'),
                      const SizedBox(width: 5),
                      _timerBox('51'),
                    ],
                  ),
                ),

                const SizedBox(height: 17),

                // =====================================================
                // FEATURED PRODUCTS
                // =====================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF182235),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllProductsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See All →',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // =====================================================
                // PRODUCT GRID
                // =====================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
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

                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
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
                ),

                const SizedBox(height: 12),

                // =====================================================
                // BOTTOM BENEFITS
                // =====================================================
                Row(
                  children: [
                    _benefitCard(
                      Icons.shield_outlined,
                      '100% Safe',
                      'Certified products',
                    ),

                    const SizedBox(width: 6),

                    _benefitCard(
                      Icons.local_shipping_outlined,
                      'Fast Delivery',
                      'Same day',
                    ),

                    const SizedBox(width: 6),

                    _benefitCard(
                      Icons.workspace_premium_outlined,
                      'Top Brands',
                      'Trusted quality',
                    ),
                  ],
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY WIDGET
  // ============================================================

  Widget _category(String emoji, String title, Color background) {
    return Container(
      width: 55,
      margin: const EdgeInsets.only(right: 9),
      child: Column(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 7.5, color: Color(0xFF4F596B)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIMER BOX
  // ============================================================

  static Widget _timerBox(String text) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BENEFIT CARD
  // ============================================================

  Widget _benefitCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFECE8E3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFF6600), size: 17),

            const SizedBox(height: 3),

            Text(
              title,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4F596B),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              style: const TextStyle(fontSize: 7, color: Color(0xFF9BA1AE)),
            ),
          ],
        ),
      ),
    );
  }
}
