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

  // FIXED: Changed row mapping parameter type to dynamic to safely read binary blobs alongside text strings
  factory User.fromRow(Map<String, dynamic> row) {
    Uint8List? parsedImage;

    // FIXED: Directly check the row map for the "image" field coming back from MySQLService
    final rawImage = row['image'];

    if (rawImage is Uint8List) {
      parsedImage = rawImage;
    } else if (rawImage is List<int>) {
      parsedImage = Uint8List.fromList(rawImage);
    } else if (rawImage is String && rawImage.trim().isNotEmpty) {
      // Fallback fallback filter mapping in case it gets stringified as textual elements
      final String textImage = rawImage.trim();
      if (textImage.startsWith('[') && textImage.endsWith(']')) {
        try {
          final cleaned = textImage.substring(1, textImage.length - 1);
          final bytes = cleaned
              .split(',')
              .map((value) => int.parse(value.trim()))
              .toList();
          parsedImage = Uint8List.fromList(bytes);
        } catch (_) {
          parsedImage = null;
        }
      }
    }

    return User(
      id: row['id']?.toString() ?? '',
      fullName:
          row['fullName']?.toString() ?? row['full_name']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      address: row['address']?.toString(),
      password: row['password']?.toString() ?? '',
      status: row['status']?.toString() ?? 'Active',
      createdAt: row['createdAt'] != null
          ? DateTime.tryParse(row['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isAdmin:
          row['isAdmin'] == '1' ||
          row['isAdmin'] == 1 ||
          row['isAdmin'] == 'true' ||
          row['isAdmin'] == true,

      use2FA:
          row['use2FA'] == '1' ||
          row['use2FA'] == 1 ||
          row['use2FA'] == 'true' ||
          row['use2FA'] == true,

      image: parsedImage,
    );
  }
}
