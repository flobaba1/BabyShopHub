class UserCard {
  final String id;
  final String cardHolder;
  final String? cardToken;
  final String cardLastFour;
  final String expiryDate; // Format: MM/YYYY or MM/YY
  final String userId;

  UserCard({
    required this.id,
    required this.cardHolder,
    this.cardToken,
    required this.cardLastFour,
    required this.expiryDate,
    required this.userId,
  });

  factory UserCard.fromRow(Map<String, String?> row) {
    return UserCard(
      id: row['id'] ?? '',
      cardHolder: row['cardHolder'] ?? '',
      cardToken: row['cardToken'],
      cardLastFour: row['cardLastFour'] ?? '',
      expiryDate: row['expiryDate'] ?? '',
      userId: row['userId'] ?? '',
    );
  }
}