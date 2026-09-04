import 'package:mysql_client/mysql_client.dart';
import 'package:baby_shop_hub/utilities/models/product.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';
import 'package:baby_shop_hub/utilities/models/cart_item.dart';
import 'package:baby_shop_hub/utilities/models/category.dart';
import 'package:baby_shop_hub/utilities/security_helper.dart';
import 'package:baby_shop_hub/utilities/models/user_card.dart';
import 'package:baby_shop_hub/utilities/models/wishlist_item.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:baby_shop_hub/env/env.dart';
import 'dart:developer';

class MySQLService {
  static final MySQLService _instance = MySQLService._internal();
  MySQLConnection? _connection;

  factory MySQLService() => _instance;
  MySQLService._internal();

  Timer? _idleTimer;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  Future<MySQLConnection> get connection async {
    _idleTimer?.cancel();
    _idleTimer = Timer(_timeoutDuration, _closeConnection);

    if (_connection != null && _connection!.connected) {
      return _connection!;
    }

    _connection = await MySQLConnection.createConnection(
      host: Env.mysqlHost,
      port: Env.mysqlPort,
      userName: Env.mysqlUser,
      password: Env.mysqlPassword,
      databaseName: Env.mysqlDatabase,
    );

    await _connection!.connect();
    log("MySQL connection established successfully.");
    return _connection!;
  }

  // ===========================================================================
  // AUTHENTICATION & USERS

  Future<bool> createUser({
    required String fullName,
    required String email,
    required String plainPassword,
    String? address,
    bool isAdmin = false,
    Uint8List? imageBytes,
  }) async {
    final conn = await connection;

    final String hashedPassword = SecurityHelper.hashPassword(plainPassword);

    final result = await conn.execute(
      "INSERT INTO Users "
      "(id, fullName, email, address, password, isAdmin, use2FA, image) "
      "VALUES (UUID(), :fullName, :email, :address, :password, :isAdmin, :use2FA, :image)",
      {
        "fullName": fullName,
        "email": email,
        "address": address,
        "password": hashedPassword,
        "isAdmin": isAdmin ? 1 : 0,
        "use2FA": 0,
        "image": imageBytes,
      },
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<User> authenticateUser({
    required String email,
    required String plainPassword,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, fullName, email, address, password, status, "
      "createdAt, isAdmin, use2FA "
      "FROM Users WHERE email = :email",
      {"email": email},
    );

    if (result.rows.isEmpty) {
      throw Exception("No account found with this email address.");
    }

    final row = result.rows.first.assoc();

    final String storedHash = row['password'] ?? '';
    final String userStatus = row['status'] ?? '';

    if (userStatus != 'Active') {
      throw Exception(
        "Your account is currently inactive. Please contact support.",
      );
    }

    final bool isPasswordValid = SecurityHelper.verifyPassword(
      plainPassword,
      storedHash,
    );

    if (!isPasswordValid) {
      throw Exception("Invalid password. Please try again.");
    }

    return User.fromRow(row);
  }

  /// Get the current 2FA setting for a user.
  Future<bool> getTwoFactorStatus(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT use2FA FROM Users WHERE id = :id",
      {"id": userId},
    );

    if (result.rows.isEmpty) {
      throw Exception("User not found.");
    }

    final value = result.rows.first.assoc()['use2FA'];

    return value == '1' || value == 'true';
  }

  /// Update the 2FA setting for a user.
  Future<bool> updateTwoFactorStatus({
    required String userId,
    required bool enabled,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "UPDATE Users SET use2FA = :use2FA WHERE id = :id",
      {"id": userId, "use2FA": enabled ? 1 : 0},
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception("Failed to update Two-Factor Authentication.");
    }

    return true;
  }

  Future<bool> updateUserProfileImage({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "UPDATE Users SET image = :image WHERE id = :id",
      {"id": userId, "image": imageBytes},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<Uint8List?> getUserProfileImage(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT image FROM Users WHERE id = :id",
      {"id": userId},
    );

    if (result.rows.isEmpty) return null;

    final row = result.rows.first;
    return row.colAt(0) as Uint8List?;
  }

  // ===========================================================================
  // CART ITEMS CRUD
  // ===========================================================================

  Future<bool> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    final conn = await connection;

    final existing = await conn.execute(
      "SELECT id, quantity FROM CartItems "
      "WHERE userId = :userId AND productId = :productId",
      {"userId": userId, "productId": productId},
    );

    if (existing.rows.isNotEmpty) {
      final currentQty = int.parse(
        existing.rows.first.assoc()['quantity'] ?? '0',
      );

      final result = await conn.execute(
        "UPDATE CartItems SET quantity = :quantity WHERE id = :id",
        {
          "quantity": currentQty + quantity,
          "id": existing.rows.first.assoc()['id'],
        },
      );

      return result.affectedRows.toInt() > 0;
    } else {
      final result = await conn.execute(
        "INSERT INTO CartItems "
        "(id, productId, userId, quantity) "
        "VALUES (UUID(), :productId, :userId, :quantity)",
        {"productId": productId, "userId": userId, "quantity": quantity},
      );

      return result.affectedRows.toInt() > 0;
    }
  }

  Future<List<CartItem>> getUserCart(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, productId, userId, quantity, createdAt "
      "FROM CartItems WHERE userId = :userId",
      {"userId": userId},
    );

    return result.rows.map((row) => CartItem.fromRow(row.assoc())).toList();
  }

  Future<bool> updateCartQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      return deleteCartItem(cartItemId);
    }

    final conn = await connection;

    final result = await conn.execute(
      "UPDATE CartItems SET quantity = :quantity WHERE id = :id",
      {"quantity": quantity, "id": cartItemId},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<bool> deleteCartItem(String cartItemId) async {
    final conn = await connection;

    final result = await conn.execute("DELETE FROM CartItems WHERE id = :id", {
      "id": cartItemId,
    });

    return result.affectedRows.toInt() > 0;
  }

  Future<bool> clearUserCart(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "DELETE FROM CartItems WHERE userId = :userId",
      {"userId": userId},
    );

    return result.affectedRows.toInt() > 0;
  }

  // ===========================================================================
  // PRODUCTS CRUD & IMAGE MANAGEMENT
  // ===========================================================================

  Future<bool> createProduct({
    required String name,
    required String categoryId,
    required double price,
    required int quantity,
    String? brand,
    String? badge,
    double rating = 0.00,
    double discount = 0.00,
    String? description,
    Uint8List? imageBytes,
  }) async {
    final conn = await connection;

    try {
      final result = await conn.execute(
        "INSERT INTO Products "
        "(id, name, categoryId, price, quantity, brand, badge, rating, "
        "discount, description, image) "
        "VALUES (UUID(), :name, :categoryId, :price, :quantity, :brand, "
        ":badge, :rating, :discount, :description, :image)",
        {
          "name": name,
          "categoryId": categoryId,
          "price": price,
          "quantity": quantity,
          "brand": brand,
          "badge": badge,
          "rating": rating,
          "discount": discount,
          "description": description,
          "image": imageBytes,
        },
      );

      return result.affectedRows.toInt() > 0;
    } catch (e) {
      throw Exception("Failed to create product: ${e.toString()}");
    }
  }

  Future<Product> getProductById(String id) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, name, categoryId, price, quantity, brand, badge, rating, "
      "discount, description, createdAt "
      "FROM Products WHERE id = :id",
      {"id": id},
    );

    if (result.rows.isEmpty) {
      throw Exception("Product with ID '$id' was not found.");
    }

    return Product.fromRow(result.rows.first.assoc());
  }

  Future<Uint8List?> getProductImage(String productId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT image FROM Products WHERE id = :id",
      {"id": productId},
    );

    if (result.rows.isEmpty) {
      throw Exception("Product with ID '$productId' was not found.");
    }

    final row = result.rows.first;
    return row.colAt(0) as Uint8List?;
  }

  Future<List<Product>> fetchProductsPaginated({
    required int offset,
    required int limit,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, name, categoryId, price, quantity, brand, badge, rating, "
      "discount, description, createdAt "
      "FROM Products ORDER BY createdAt DESC "
      "LIMIT :limit OFFSET :offset",
      {"limit": limit, "offset": offset},
    );

    return result.rows.map((row) => Product.fromRow(row.assoc())).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, name, categoryId, price, quantity, brand, badge, rating, "
      "discount, description, createdAt "
      "FROM Products WHERE categoryId = :categoryId "
      "ORDER BY createdAt DESC",
      {"categoryId": categoryId},
    );

    return result.rows.map((row) => Product.fromRow(row.assoc())).toList();
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String categoryId,
    required double price,
    required int quantity,
    String? brand,
    String? badge,
    double? rating,
    double? discount,
    String? description,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "UPDATE Products SET "
      "name = :name, "
      "categoryId = :categoryId, "
      "price = :price, "
      "quantity = :quantity, "
      "brand = :brand, "
      "badge = :badge, "
      "rating = COALESCE(:rating, rating), "
      "discount = COALESCE(:discount, discount), "
      "description = :description "
      "WHERE id = :id",
      {
        "id": id,
        "name": name,
        "categoryId": categoryId,
        "price": price,
        "quantity": quantity,
        "brand": brand,
        "badge": badge,
        "rating": rating,
        "discount": discount,
        "description": description,
      },
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception(
        "Failed to update product. Product ID '$id' does not exist.",
      );
    }

    return true;
  }

  Future<bool> updateProductImage({
    required String productId,
    required Uint8List imageBytes,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "UPDATE Products SET image = :image WHERE id = :id",
      {"id": productId, "image": imageBytes},
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception(
        "Failed to upload image. Product ID '$productId' does not exist.",
      );
    }

    return true;
  }

  Future<bool> deleteProduct(String id) async {
    final conn = await connection;

    final result = await conn.execute("DELETE FROM Products WHERE id = :id", {
      "id": id,
    });

    if (result.affectedRows.toInt() == 0) {
      throw Exception(
        "Failed to delete product. Product ID '$id' was not found.",
      );
    }

    return true;
  }

  // USER CARDS CRUD

  Future<bool> addUserCard({
    required String userId,
    required String cardHolder,
    required String cardLastFour,
    required String expiryDate,
    String? cardToken,
  }) async {
    final conn = await connection;

    try {
      final result = await conn.execute(
        "INSERT INTO UserCards "
        "(id, userId, cardHolder, cardLastFour, expiryDate, cardToken) "
        "VALUES (UUID(), :userId, :cardHolder, :cardLastFour, "
        ":expiryDate, :cardToken)",
        {
          "userId": userId,
          "cardHolder": cardHolder,
          "cardLastFour": cardLastFour,
          "expiryDate": expiryDate,
          "cardToken": cardToken,
        },
      );

      return result.affectedRows.toInt() > 0;
    } catch (e) {
      throw Exception("Failed to add user card: ${e.toString()}");
    }
  }

  Future<List<UserCard>> getUserCards(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, cardHolder, cardToken, cardLastFour, expiryDate, userId "
      "FROM UserCards WHERE userId = :userId",
      {"userId": userId},
    );

    return result.rows.map((row) => UserCard.fromRow(row.assoc())).toList();
  }

  Future<UserCard> getCardById(String cardId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, cardHolder, cardToken, cardLastFour, expiryDate, userId "
      "FROM UserCards WHERE id = :id",
      {"id": cardId},
    );

    if (result.rows.isEmpty) {
      throw Exception("Payment card with ID '$cardId' not found.");
    }

    return UserCard.fromRow(result.rows.first.assoc());
  }

  Future<bool> deleteUserCard(String cardId) async {
    final conn = await connection;

    final result = await conn.execute("DELETE FROM UserCards WHERE id = :id", {
      "id": cardId,
    });

    if (result.affectedRows.toInt() == 0) {
      throw Exception(
        "Failed to delete card. Card ID '$cardId' was not found.",
      );
    }

    return true;
  }

  // ===========================================================================
  // USER WISHLIST CRUD
  // ===========================================================================

  Future<bool> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    final conn = await connection;

    try {
      final result = await conn.execute(
        "INSERT INTO UserWishlist (id, userId, productId) "
        "VALUES (UUID(), :userId, :productId) "
        "ON DUPLICATE KEY UPDATE id = id",
        {"userId": userId, "productId": productId},
      );

      return result.affectedRows.toInt() > 0;
    } catch (e) {
      throw Exception("Failed to add item to wishlist: ${e.toString()}");
    }
  }

  Future<List<WishlistItem>> getUserWishlist(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, userId, productId "
      "FROM UserWishlist WHERE userId = :userId",
      {"userId": userId},
    );

    return result.rows.map((row) => WishlistItem.fromRow(row.assoc())).toList();
  }

  Future<bool> isProductInWishlist({
    required String userId,
    required String productId,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id FROM UserWishlist "
      "WHERE userId = :userId AND productId = :productId",
      {"userId": userId, "productId": productId},
    );

    return result.rows.isNotEmpty;
  }

  Future<bool> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "DELETE FROM UserWishlist "
      "WHERE userId = :userId AND productId = :productId",
      {"userId": userId, "productId": productId},
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception("Item not found in wishlist.");
    }

    return true;
  }

  Future<bool> toggleWishlist({
    required String userId,
    required String productId,
  }) async {
    final bool exists = await isProductInWishlist(
      userId: userId,
      productId: productId,
    );

    if (exists) {
      return await removeFromWishlist(userId: userId, productId: productId);
    } else {
      return await addToWishlist(userId: userId, productId: productId);
    }
  }

  // ===========================================================================
  // DISPOSAL AND CONNECTION MANAGEMENT
  // ===========================================================================

  Future<void> _closeConnection() async {
    if (_connection != null && _connection!.connected) {
      await _connection!.close();
      _connection = null;
    }
  }

  Future<void> dispose() async {
    _idleTimer?.cancel();
    await _closeConnection();
  }

  Future<User> getUserById(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, fullName, email, address, password, status, "
      "createdAt, isAdmin, use2FA "
      "FROM Users WHERE id = :id",
      {"id": userId},
    );

    if (result.rows.isEmpty) {
      throw Exception("User not found.");
    }

    final row = result.rows.first.assoc();

    final Uint8List? imageBytes = await getUserProfileImage(userId);

    return User.fromRow(row, imageBlob: imageBytes);
  }

  Future<bool> updateUserProfile({
    required String userId,
    required String fullName,
    required String email,
    String? address,
  }) async {
    final conn = await connection;
    final result = await conn.execute(
      "UPDATE Users SET "
      "fullName = :fullName, "
      "email = :email, "
      "address = :address "
      "WHERE id = :id",
      {"id": userId, "fullName": fullName, "email": email, "address": address},
    );
    return result.affectedRows.toInt() > 0;
  }
}
