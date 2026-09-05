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
  final Uint8List? image;

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

  factory Product.fromRow(Map<String, dynamic> row) {
    return Product(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      categoryId: row['categoryId']?.toString() ?? '',
      price: double.tryParse(row['price']?.toString() ?? '0.0') ?? 0.0,
      quantity: int.tryParse(row['quantity']?.toString() ?? '0') ?? 0,
      brand: row['brand']?.toString(),
      badge: row['badge']?.toString(),
      rating: double.tryParse(row['rating']?.toString() ?? '0.0') ?? 0.0,
      discount: double.tryParse(row['discount']?.toString() ?? '0.0') ?? 0.0,
      description: row['description']?.toString(),
      createdAt: row['createdAt'] != null
          ? (row['createdAt'] is DateTime
                ? row['createdAt'] as DateTime
                : DateTime.tryParse(row['createdAt'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      image: null,
    );
  }
}
