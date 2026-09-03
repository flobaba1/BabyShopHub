class CartItem {
  final String id;
  final String productId;
  final String userId;
  final int quantity;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.userId,
    this.quantity = 1,
    required this.createdAt,
  });

  factory CartItem.fromRow(Map<String, String?> row) {
    return CartItem(
      id: row['id'] ?? '',
      productId: row['productId'] ?? '',
      userId: row['userId'] ?? '',
      quantity: int.tryParse(row['quantity'] ?? '1') ?? 1,
      createdAt: row['createdAt'] != null
          ? DateTime.parse(row['createdAt']!)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toSqlParams() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'quantity': quantity,
    };
  }
}