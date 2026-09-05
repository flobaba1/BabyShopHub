import 'dart:typed_data';

class User {
  final String id;
  final String fullName;
  final String email;
  final String? address;
  final String? password;
  final String status;
  final DateTime? createdAt;
  final bool isAdmin;
  final bool use2FA;
  final Uint8List? image;
  final metadata = <String, dynamic>{}; // For any additional metadata

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.address,
    this.password,
    this.status = 'Active',
    this.createdAt,
    this.isAdmin = false,
    this.use2FA = false,
    this.image,
  });

  factory User.fromRow(Map<String, String?> row, {Uint8List? imageBlob}) {
    return User(
      id: row['id'] ?? '',
      fullName: row['fullName'] ?? '',
      email: row['email'] ?? '',
      address: row['address'],
      password: row['password'] ?? '',
      status: row['status'] ?? 'Active',
      createdAt: row['createdAt'] != null
          ? DateTime.parse(row['createdAt']!)
          : DateTime.now(),
      isAdmin: row['isAdmin'] == '1' || row['isAdmin'] == 'true',

      // Read the 2FA setting from MySQL
      use2FA: row['use2FA'] == '1' || row['use2FA'] == 'true',

      image: imageBlob,
    );
  }
}
