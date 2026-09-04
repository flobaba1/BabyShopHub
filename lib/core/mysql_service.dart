import 'package:mysql_client/mysql_client.dart';
import 'package:baby_shop_hub/utilities/models/product.dart';
import 'package:flutter/material.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';
import 'package:baby_shop_hub/utilities/models/cart_item.dart';
import 'package:baby_shop_hub/utilities/models/category.dart';
import 'package:baby_shop_hub/utilities/security_helper.dart';
import 'package:baby_shop_hub/utilities/models/user_card.dart';
import 'package:baby_shop_hub/utilities/models/wishlist_item.dart';
import 'package:baby_shop_hub/screens/admin/admin_dashboard_view.dart';
import 'package:baby_shop_hub/utilities/models/dashboard_models.dart';
import 'package:baby_shop_hub/utilities/widgets/dashboard_widgets.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

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

  ///  Fetch all registered users
  Future<List<User>> fetchAllUsers() async {
    final conn = await connection;
    final results = await conn.execute(
      "SELECT id, fullName, email, address, password, status, createdAt, isAdmin FROM Users ORDER BY createdAt DESC",
    );

    List<User> users = [];
    for (final row in results.rows) {
      final Map<String, String?> rowMap = row.assoc();
      users.add(User.fromRow(rowMap));
    }

    return users;
  }

  ///  Fetch total orders count grouped by userId
  Future<Map<String, int>> fetchUserOrderCounts() async {
    final conn = await connection;
    final results = await conn.execute(
      "SELECT userId, COUNT(*) as total_orders FROM Orders GROUP BY userId",
    );

    Map<String, int> counts = {};
    for (final row in results.rows) {
      final data = row.assoc();
      final userId = data['userId']?.toString();
      final total = int.tryParse(data['total_orders'] ?? '0') ?? 0;

      if (userId != null) {
        counts[userId] = total;
      }
    }
    return counts;
  }

  ///  Update user status 
  Future<bool> updateUserStatus(String userId, String status) async {
    final conn = await connection;
    final result = await conn.execute(
      "UPDATE Users SET status = :status WHERE id = :id",
      {"status": status, "id": userId},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<List<DashboardMetric>> fetchDashboardMetrics() async {
    final conn = await connection;

    final revResult = await conn.execute(
      "SELECT COALESCE(SUM(totalAmount), 0) AS total FROM Orders",
    );
    final ordersResult = await conn.execute(
      "SELECT COUNT(*) AS total FROM Orders",
    );
    final productsResult = await conn.execute(
      "SELECT COUNT(*) AS total FROM Products",
    );
    final usersResult = await conn.execute(
      "SELECT COUNT(*) AS total FROM Users",
    );

    final double totalRevenue =
        double.tryParse(
          revResult.rows.first.assoc()['total']?.toString() ?? '0',
        ) ??
        0.0;
    final int totalOrders =
        int.tryParse(
          ordersResult.rows.first.assoc()['total']?.toString() ?? '0',
        ) ??
        0;
    final int totalProducts =
        int.tryParse(
          productsResult.rows.first.assoc()['total']?.toString() ?? '0',
        ) ??
        0;
    final int totalUsers =
        int.tryParse(
          usersResult.rows.first.assoc()['total']?.toString() ?? '0',
        ) ??
        0;

    return [
      DashboardMetric(
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xFF16A34A),
        iconBg: const Color(0xFFDCFCE7),
        value: '\$${totalRevenue.toStringAsFixed(0)}',
        label: 'Revenue',
        subtext: 'Total revenue',
      ),
      DashboardMetric(
        icon: Icons.shopping_bag_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFDBEAFE),
        value: '$totalOrders',
        label: 'Orders',
        subtext: 'Total placed',
      ),
      DashboardMetric(
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF9333EA),
        iconBg: const Color(0xFFF3E8FF),
        value: '$totalProducts',
        label: 'Products',
        subtext: 'Active listings',
      ),
      DashboardMetric(
        icon: Icons.people_outline_rounded,
        iconColor: const Color(0xFFEA580C),
        iconBg: const Color(0xFFFFEDD5),
        value: '$totalUsers',
        label: 'Users',
        subtext: 'Registered users',
      ),
    ];
  }

  // Fetch recent 5 orders from MySQL
  Future<List<RecentOrder>> fetchRecentOrders() async {
    final conn = await connection;
    final results = await conn.execute(
      "SELECT id, createdAt, status, totalAmount FROM Orders ORDER BY createdAt DESC LIMIT 5",
    );

    return results.rows.map((row) {
      final data = row.assoc();
      final status = data['status']?.toString() ?? 'Pending';

      Color bg = const Color(0xFFFEF3C7);
      Color text = const Color(0xFFD97706);

      if (status.toLowerCase() == 'delivered') {
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
      } else if (status.toLowerCase() == 'shipped') {
        bg = const Color(0xFFF3E8FF);
        text = const Color(0xFF9333EA);
      } else if (status.toLowerCase() == 'cancelled') {
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
      }

      return RecentOrder(
        id: data['id']?.toString() ?? '',
        date: data['created_at']?.toString().split(' ')[0] ?? '',
        status: status,
        price: '\$${data['total_amount']?.toString() ?? '0'}',
        statusBg: bg,
        statusText: text,
      );
    }).toList();
  }

  /// Verify User credentials during Login
  /// Throws an [Exception] with specific details if authentication fails.
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

    // 3. Invalid password
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

  // fetch categories
  Future<List<Category>> fetchCategories() async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, name FROM Categories ORDER BY name ASC",
    );

    return result.rows.map((row) => Category.fromRow(row.assoc())).toList();
  }

  /// Update Cart Item Quantity
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
      return null;
    }

    final dynamic rawImage = result.rows.first.colAt(0);

    if (rawImage == null) {
      return null;
    }

    // If database already returns real binary bytes
    if (rawImage is Uint8List) {
      return rawImage;
    }

    // If database returns List<int>
    if (rawImage is List<int>) {
      return Uint8List.fromList(rawImage);
    }

    if (rawImage is String) {
      final text = rawImage.trim();

      if (text.startsWith('[') && text.endsWith(']')) {
        try {
          final cleaned = text.substring(1, text.length - 1);

          final bytes = cleaned
              .split(',')
              .map((value) => int.parse(value.trim()))
              .toList();

          return Uint8List.fromList(bytes);
        } catch (e) {
          log("Failed to convert image list: $e");
          return null;
        }
      }

      try {
        return base64Decode(text);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  Future<List<Product>> fetchProductsPaginated({
    required int offset,
    required int limit,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, name, categoryId, price, quantity, brand, badge, "
      "rating, discount, description, createdAt "
      "FROM Products "
      "ORDER BY createdAt DESC "
      "LIMIT :limit OFFSET :offset",
      {"limit": limit, "offset": offset},
    );

    return result.rows.map((row) {
      return Product.fromRow(row.assoc());
    }).toList();
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

  /// Update or Upload Product Image BLOB
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
    Uint8List? imageBytes,
  }) async {
    final conn = await connection;

    // Check if product exists
    final checkResult = await conn.execute(
      "SELECT id FROM Products WHERE id = :id",
      {"id": id},
    );

    if (checkResult.rows.isEmpty) {
      throw Exception("Product ID '$id' does not exist in the Products table.");
    }

    // Update normal product information
    await conn.execute(
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

    // Update image only if the user selected a new image
    if (imageBytes != null) {
      await conn.execute("UPDATE Products SET image = :image WHERE id = :id", {
        "id": id,
        "image": imageBytes,
      });
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
