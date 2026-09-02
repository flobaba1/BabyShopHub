import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Diapers',
      'count': '142 products',
      'icon': Icons.baby_changing_station,
      'color': Color(0xFFFEECE2),
    },
    {
      'name': 'Baby Food',
      'count': '89 products',
      'icon': Icons.restaurant,
      'color': Color(0xFFE1F4E5),
    },
    {
      'name': 'Clothing',
      'count': '210 products',
      'icon': Icons.checkroom,
      'color': Color(0xFFE1ECFD),
    },
    {
      'name': 'Toys',
      'count': '76 products',
      'icon': Icons.toys,
      'color': Color(0xFFFFF7E2),
    },
    {
      'name': 'Bath & Care',
      'count': '54 products',
      'icon': Icons.bathtub,
      'color': Color(0xFFEFE2FE),
    },
    {
      'name': 'Feeding',
      'count': '98 products',
      'icon': Icons.child_friendly,
      'color': Color(0xFFE1F5FE),
    },
    {
      'name': 'Accessories',
      'count': '67 products',
      'icon': Icons.backpack,
      'color': Color(0xFFFEE2EC),
    },
  ];

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF7F848F),
                ),
              ),

              const SizedBox(height: 24),

              GridView.builder(
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

                  return _CategoryCard(
                    name: category['name'],
                    count: category['count'],
                    icon: category['icon'],
                    backgroundColor: category['color'],
                  );
                },
              ),

              const SizedBox(height: 30),

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
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                      ),
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
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String count;
  final IconData icon;
  final Color backgroundColor;

  const _CategoryCard({
    required this.name,
    required this.count,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(
                icon,
                size: 32,
                color: const Color(0xFF1D2338),
              ),

              const SizedBox(height: 10),

              Text(
                name,
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
    );
  }
}