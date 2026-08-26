class Product {
  final int id;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final String? badgeText;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    this.badgeText,
  });

  factory Product.fromRow(Map<String, String?> row) {
    return Product(
      id: int.parse(row['id']!),
      name: row['name'] ?? '',
      brand: row['brand'] ?? '',
      price: double.parse(row['price'] ?? '0.0'),
      imageUrl: row['image_url'] ?? '',
      badgeText: row['badge_text'],
    );
  }
}