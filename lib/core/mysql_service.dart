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
  // AUTHENTICATION & USERS (WITH BCRYPT & BLOB IMAGES)
  // ===========================================================================

  /// Create a new User with BCrypt Password Hashing and optional Profile Image (BLOB)
  Future<bool> createUser({
    required String fullName,
    required String email,
    required String plainPassword,
    String? address,
    bool isAdmin = false,
    Uint8List? imageBytes,
  }) async {
    final conn = await connection;

    // 1. Hash the plain text password before database insertion
    final String hashedPassword = SecurityHelper.hashPassword(plainPassword);

    // 2. Insert user with hashed password and BLOB image
    final result = await conn.execute(
      "INSERT INTO Users (id, fullName, email, address, password, isAdmin, image) "
      "VALUES (UUID(), :fullName, :email, :address, :password, :isAdmin, :image)",
      {
        "fullName": fullName,
        "email": email,
        "address": address,
        "password": hashedPassword,
        "isAdmin": isAdmin ? 1 : 0,
        "image": imageBytes, // Passes raw bytes directly into mediumblob column
      },
    );

    return result.affectedRows.toInt() > 0;
  }

  /// Verify User credentials during Login
  /// Throws an [Exception] with specific details if authentication fails.
  Future<User> authenticateUser({
    required String email,
    required String plainPassword,
  }) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, fullName, email, address, password, status, createdAt, isAdmin FROM Users WHERE email = :email",
      {"email": email},
    );

    // 1. User not found
    if (result.rows.isEmpty) {
      throw Exception("No account found with this email address.");
    }

    final row = result.rows.first.assoc();
    final String storedHash = row['password'] ?? '';
    final String userStatus = row['status'] ?? '';

    // 2. Inactive account
    if (userStatus != 'Active') {
      throw Exception("Your account is currently inactive. Please contact support.");
    }

    // 3. Invalid password
    final bool isPasswordValid = SecurityHelper.verifyPassword(plainPassword, storedHash);
    if (!isPasswordValid) {
      throw Exception("Invalid password. Please try again.");
    }

    return User.fromRow(row);
  }

  /// Upload or Update Profile Image (BLOB)
  Future<bool> updateUserProfileImage({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final conn = await connection;
    final result = await conn.execute(
      "UPDATE Users SET image = :image WHERE id = :id",
      {
        "id": userId,
        "image": imageBytes,
      },
    );
    return result.affectedRows.toInt() > 0;
  }

  /// Fetch User Profile Image BLOB Bytes
  Future<Uint8List?> getUserProfileImage(String userId) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT image FROM Users WHERE id = :id",
      {"id": userId},
    );

    if (result.rows.isEmpty) return null;

    // Extract binary bytes from column
    final row = result.rows.first;
    return row.colAt(0) as Uint8List?;
  }

  // ===========================================================================
  // CART ITEMS CRUD
  // ===========================================================================

  /// Add Item to Cart (or increment quantity if already exists)
  Future<bool> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    final conn = await connection;

    // Check if item already exists in cart for this user
    final existing = await conn.execute(
      "SELECT id, quantity FROM CartItems WHERE userId = :userId AND productId = :productId",
      {"userId": userId, "productId": productId},
    );

    if (existing.rows.isNotEmpty) {
      final currentQty = int.parse(existing.rows.first.assoc()['quantity'] ?? '0');
      final result = await conn.execute(
        "UPDATE CartItems SET quantity = :quantity WHERE id = :id",
        {"quantity": currentQty + quantity, "id": existing.rows.first.assoc()['id']},
      );
      return result.affectedRows.toInt() > 0;
    } else {
      final result = await conn.execute(
        "INSERT INTO CartItems (id, productId, userId, quantity) VALUES (UUID(), :productId, :userId, :quantity)",
        {"productId": productId, "userId": userId, "quantity": quantity},
      );
      return result.affectedRows.toInt() > 0;
    }
  }

  /// Get All Cart Items for a User
  Future<List<CartItem>> getUserCart(String userId) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, productId, userId, quantity, createdAt FROM CartItems WHERE userId = :userId",
      {"userId": userId},
    );

    return result.rows.map((row) => CartItem.fromRow(row.assoc())).toList();
  }

  /// Update Cart Item Quantity
  Future<bool> updateCartQuantity(String cartItemId, int quantity) async {
    final conn = await connection;
    if (quantity <= 0) {
      return deleteCartItem(cartItemId);
    }
    final result = await conn.execute(
      "UPDATE CartItems SET quantity = :quantity WHERE id = :id",
      {"quantity": quantity, "id": cartItemId},
    );
    return result.affectedRows.toInt() > 0;
  }

  /// Remove Single Item from Cart
  Future<bool> deleteCartItem(String cartItemId) async {
    final conn = await connection;
    final result = await conn.execute(
      "DELETE FROM CartItems WHERE id = :id",
      {"id": cartItemId},
    );
    return result.affectedRows.toInt() > 0;
  }

  /// Clear Entire Cart for a User
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

  /// Create a new Product with optional BLOB Image
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
        "(id, name, categoryId, price, quantity, brand, badge, rating, discount, description, image) "
        "VALUES (UUID(), :name, :categoryId, :price, :quantity, :brand, :badge, :rating, :discount, :description, :image)",
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
          "image": imageBytes, // Raw Uint8List bound directly to mediumblob
        },
      );

      return result.affectedRows.toInt() > 0;
    } catch (e) {
      throw Exception("Failed to create product: ${e.toString()}");
    }
  }

  /// Get Product by ID (Excludes BLOB data for performance)
  Future<Product> getProductById(String id) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, name, categoryId, price, quantity, brand, badge, rating, discount, description, createdAt "
      "FROM Products WHERE id = :id",
      {"id": id},
    );

    if (result.rows.isEmpty) {
      throw Exception("Product with ID '$id' was not found.");
    }

    return Product.fromRow(result.rows.first.assoc());
  }

  /// Get Product Image BLOB Bytes
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

  /// Fetch Paginated Products List (Lightweight fetch without BLOB payloads)
  Future<List<Product>> fetchProductsPaginated({
    required int offset,
    required int limit,
  }) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, name, categoryId, price, quantity, brand, badge, rating, discount, description, createdAt "
      "FROM Products "
      "ORDER BY createdAt DESC LIMIT :limit OFFSET :offset",
      {"limit": limit, "offset": offset},
    );

    return result.rows.map((row) => Product.fromRow(row.assoc())).toList();
  }

  /// Fetch Products by Category ID
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, name, categoryId, price, quantity, brand, badge, rating, discount, description, createdAt "
      "FROM Products WHERE categoryId = :categoryId ORDER BY createdAt DESC",
      {"categoryId": categoryId},
    );

    return result.rows.map((row) => Product.fromRow(row.assoc())).toList();
  }

  /// Update Product Details
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
      throw Exception("Failed to update product. Product ID '$id' does not exist.");
    }

    return true;
  }

  /// Update or Upload Product Image BLOB
  Future<bool> updateProductImage({
    required String productId,
    required Uint8List imageBytes,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "UPDATE Products SET image = :image WHERE id = :id",
      {
        "id": productId,
        "image": imageBytes,
      },
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception("Failed to upload image. Product ID '$productId' does not exist.");
    }

    return true;
  }

  /// Delete Product
  Future<bool> deleteProduct(String id) async {
    final conn = await connection;

    final result = await conn.execute(
      "DELETE FROM Products WHERE id = :id",
      {"id": id},
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception("Failed to delete product. Product ID '$id' was not found.");
    }

    return true;
  }

  // ===========================================================================
  // USER CARDS CRUD
  // ===========================================================================

  /// Save a new user payment card
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
        "INSERT INTO UserCards (id, userId, cardHolder, cardLastFour, expiryDate, cardToken) "
        "VALUES (UUID(), :userId, :cardHolder, :cardLastFour, :expiryDate, :cardToken)",
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

  /// Fetch all saved payment cards for a specific user
  Future<List<UserCard>> getUserCards(String userId) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, cardHolder, cardToken, cardLastFour, expiryDate, userId "
      "FROM UserCards WHERE userId = :userId",
      {"userId": userId},
    );

    return result.rows.map((row) => UserCard.fromRow(row.assoc())).toList();
  }

  /// Fetch a specific card by ID
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

  /// Remove a saved card by ID
  Future<bool> deleteUserCard(String cardId) async {
    final conn = await connection;
    final result = await conn.execute(
      "DELETE FROM UserCards WHERE id = :id",
      {"id": cardId},
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception("Failed to delete card. Card ID '$cardId' was not found.");
    }

    return true;
  }

  // ===========================================================================
  // USER WISHLIST CRUD
  // ===========================================================================

  /// Add a product to user wishlist (Ignores duplicate entries safely)
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
        {
          "userId": userId,
          "productId": productId,
        },
      );
      return result.affectedRows.toInt() > 0;
    } catch (e) {
      throw Exception("Failed to add item to wishlist: ${e.toString()}");
    }
  }

  /// Fetch all wishlist items for a specific user
  Future<List<WishlistItem>> getUserWishlist(String userId) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, userId, productId FROM UserWishlist WHERE userId = :userId",
      {"userId": userId},
    );

    return result.rows.map((row) => WishlistItem.fromRow(row.assoc())).toList();
  }

  /// Check if a product is in the user's wishlist
  Future<bool> isProductInWishlist({
    required String userId,
    required String productId,
  }) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id FROM UserWishlist WHERE userId = :userId AND productId = :productId",
      {
        "userId": userId,
        "productId": productId,
      },
    );

    return result.rows.isNotEmpty;
  }

  /// Remove a specific product from user wishlist
  Future<bool> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    final conn = await connection;
    final result = await conn.execute(
      "DELETE FROM UserWishlist WHERE userId = :userId AND productId = :productId",
      {
        "userId": userId,
        "productId": productId,
      },
    );

    if (result.affectedRows.toInt() == 0) {
      throw Exception("Item not found in wishlist.");
    }

    return true;
  }

  /// Toggle Wishlist Status (Adds if absent, removes if present)
  Future<bool> toggleWishlist({
    required String userId,
    required String productId,
  }) async {
    final bool exists = await isProductInWishlist(userId: userId, productId: productId);
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
}