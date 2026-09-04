import 'dart:typed_data';

class User {
  final String id;
  final String fullName;
  final String email;
  final String? address;
  final String password;
  final String status;
  final DateTime createdAt;
  final bool isAdmin;
  final Uint8List? image; // BLOB Data

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.address,
    required this.password,
    this.status = 'Active',
    required this.createdAt,
    this.isAdmin = false,
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
      image: imageBlob,
    );
  }
}
