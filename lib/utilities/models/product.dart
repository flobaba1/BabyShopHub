import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final int quantity;
  final String? brand;
  final String? badge;
  final double rating;
  final double discount;
  final String? description;
  final DateTime createdAt;
  final Uint8List? image; // Stores mediumblob binary data

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.quantity,
    this.brand,
    this.badge,
    this.rating = 0.0,
    this.discount = 0.0,
    this.description,
    required this.createdAt,
    this.image,
  });

  /// Factory constructor to deserialize database row maps
  factory Product.fromRow(Map<String, String?> row, {Uint8List? imageBlob}) {
    return Product(
      id: row['id'] ?? '',
      name: row['name'] ?? '',
      categoryId: row['categoryId'] ?? '',
      price: double.tryParse(row['price'] ?? '0.0') ?? 0.0,
      quantity: int.tryParse(row['quantity'] ?? '0') ?? 0,
      brand: row['brand'],
      badge: row['badge'],
      rating: double.tryParse(row['rating'] ?? '0.0') ?? 0.0,
      discount: double.tryParse(row['discount'] ?? '0.0') ?? 0.0,
      description: row['description'],
      createdAt: row['createdAt'] != null
          ? DateTime.parse(row['createdAt']!)
          : DateTime.now(),
      image: imageBlob,
    );
  }
}