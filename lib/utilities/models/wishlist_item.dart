class WishlistItem {
  final String id;
  final String userId;
  final String productId;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
  });

  factory WishlistItem.fromRow(Map<String, String?> row) {
    return WishlistItem(
      id: row['id'] ?? '',
      userId: row['userId'] ?? '',
      productId: row['productId'] ?? '',
    );
  }
}