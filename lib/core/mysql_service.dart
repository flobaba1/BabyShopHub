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
import 'package:flutter/foundation.dart' as foundation;
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import 'package:mysql_dart/mysql_dart.dart';
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

    try {
      _connection = await MySQLConnection.createConnection(
        host: Env.mysqlHost,
        port: Env.mysqlPort,
        userName: Env.mysqlUser,
        password: Env.mysqlPassword,
        databaseName: Env.mysqlDatabase,
      );

      await _connection!.connect();

      log('MySQL connection established successfully.');

      return _connection!;
    } catch (e) {
      _connection = null;

      log('Failed to establish MySQL connection: $e');

      rethrow;
    }
  }

  // ===========================================================================
  // AUTHENTICATION & USERS

  Future<bool> updateUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String? address,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      "UPDATE Users SET fullName = :fullName, email = :email, address = :address WHERE id = :id",
      {"fullName": fullName, "email": email, "address": address, "id": userId},
    );

    return result.affectedRows.toInt() > 0;
  }

  // ... rest of your code stays exactly the same

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
      final Map<String, dynamic> rowMap = row.assoc();
      users.add(User.fromRow(rowMap));
    }

    return users;
  }

  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    final conn = await connection;

    final result = await conn.execute(
      '''
    SELECT
      oi.id,
      oi.productId,
      oi.quantity,
      oi.unitPrice,
      oi.discount,
      oi.totalPrice,
      p.name,
      p.brand,
      p.image
    FROM OrderItems oi
    INNER JOIN Products p
      ON oi.productId = p.id
    WHERE oi.orderId = :orderId
    ORDER BY oi.createdAt ASC
    ''',
      {'orderId': orderId},
    );

    final items = <Map<String, dynamic>>[];

    for (final row in result.rows) {
      final data = row.assoc();

      Uint8List? imageBytes;

      try {
        imageBytes = row.typedColByName<Uint8List>('image');
      } catch (_) {
        imageBytes = _convertImageToBytes(data['image']);
      }

      items.add({...data, 'imageBytes': imageBytes});
    }

    return items;
  }

  Uint8List? _convertImageToBytes(dynamic rawImage) {
    if (rawImage == null) {
      return null;
    }

    // ------------------------------------------------------------
    // Already Uint8List
    // ------------------------------------------------------------
    if (rawImage is Uint8List) {
      return rawImage;
    }

    // ------------------------------------------------------------
    // List<int>
    // ------------------------------------------------------------
    if (rawImage is List<int>) {
      try {
        return Uint8List.fromList(rawImage);
      } catch (e) {
        debugPrint('Failed to convert List<int> to Uint8List: $e');
        return null;
      }
    }

    if (rawImage is String) {
      final text = rawImage.trim();
      if (text.startsWith('[') && text.endsWith(']')) {
        try {
          final cleaned = text.substring(1, text.length - 1);

          final bytes = cleaned
              .split(',')
              .where((value) => value.trim().isNotEmpty)
              .map((value) => int.parse(value.trim()))
              .toList();

          final result = Uint8List.fromList(bytes);

          debugPrint(
            'Image converted from List<String> representation: ${result.length} bytes',
          );

          return result;
        } catch (e) {
          debugPrint('Failed to convert image list: $e');
        }
      }

      // ----------------------------------------------------------
      // Case 2: Base64
      // ----------------------------------------------------------
      try {
        final result = base64Decode(text);

        debugPrint('Image converted from Base64: ${result.length} bytes');

        return result;
      } catch (_) {}

      try {
        final result = Uint8List.fromList(latin1.encode(rawImage));

        debugPrint(
          'Image converted from binary String: ${result.length} bytes',
        );

        return result;
      } catch (e) {
        debugPrint('Failed to convert binary image String: $e');
        return null;
      }
    }

    debugPrint('Unsupported image type: ${rawImage.runtimeType}');

    return null;
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

  /// Fetch a user by their unique user ID.
  /// Fetch a user by their unique user ID.
  Future<User> getUserById(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT id, fullName, email, address, password, status, createdAt, isAdmin, image FROM Users WHERE id = :id",
      {"id": userId},
    );

    if (result.rows.isEmpty) {
      throw Exception("User not found.");
    }

    return User.fromRow(result.rows.first.assoc());
  }

  Future<User?> validateUserEmail(String userEmail) async {
    final conn = await connection;

    final result = await conn.execute(
      "SELECT * FROM Users WHERE email = :email",
      {"email": userEmail},
    );

    if (result.rows.isEmpty) {
      log("No user found with email: $userEmail");
      return null; // Email does not exist
    }
    return User.fromRow(result.rows.first.assoc());
  }

  /// Hashes and updates a user's password in the database.
  ///
  /// Supports target identification via either [userId] or [email].
  Future<bool> updateUserPassword({
    String? userId,
    String? email,
    required String newPlainPassword,
  }) async {
    if ((userId == null || userId.isEmpty) &&
        (email == null || email.isEmpty)) {
      throw ArgumentError(
        "Either 'userId' or 'email' must be provided to update password.",
      );
    }

    final conn = await connection;

    // 1. Hash the new plain text password
    final String hashedPassword = SecurityHelper.hashPassword(newPlainPassword);

    // 2. Build conditional UPDATE query based on identifier provided
    final String query = userId != null && userId.isNotEmpty
        ? "UPDATE Users SET password = :password WHERE id = :identifier"
        : "UPDATE Users SET password = :password WHERE email = :identifier";

    final String identifier = (userId != null && userId.isNotEmpty)
        ? userId
        : email!;

    try {
      final result = await conn.execute(query, {
        "password": hashedPassword,
        "identifier": identifier,
      });

      if (result.affectedRows.toInt() == 0) {
        throw Exception("User not found with the provided details.");
      }

      return true;
    } catch (e) {
      throw Exception("Failed to update user password: ${e.toString()}");
    }
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
        value: '\₦${totalRevenue.toStringAsFixed(0)}',
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
      'SELECT image FROM Users WHERE id = :id',
      {'id': userId},
    );

    if (result.rows.isEmpty) {
      return null;
    }

    final row = result.rows.first;

    try {
      return row.typedColByName<Uint8List>('image');
    } catch (e) {
      return _convertImageToBytes(row.colByName('image'));
    }
  }

  // ============================================================
  // CART ITEMS CRUD
  // ============================================================

  Future<bool> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    final conn = await connection;

    // Get product stock and existing cart quantity.
    final result = await conn.execute(
      '''
    SELECT
      p.quantity AS stockQuantity,
      c.id AS cartItemId,
      c.quantity AS cartQuantity
    FROM Products p
    LEFT JOIN CartItems c
      ON c.productId = p.id
      AND c.userId = :userId
    WHERE p.id = :productId
    ''',
      {'userId': userId, 'productId': productId},
    );

    if (result.rows.isEmpty) {
      throw Exception('Product not found.');
    }

    final row = result.rows.first.assoc();

    final stockQuantity = int.tryParse(row['stockQuantity'] ?? '0') ?? 0;

    final existingCartQuantity = int.tryParse(row['cartQuantity'] ?? '0') ?? 0;

    if (stockQuantity <= 0) {
      throw Exception('This product is out of stock.');
    }

    final newQuantity = existingCartQuantity + quantity;

    if (newQuantity > stockQuantity) {
      final remaining = stockQuantity - existingCartQuantity;

      if (remaining <= 0) {
        throw Exception(
          'You already have the maximum available quantity in your cart.',
        );
      }

      throw Exception('Only $remaining more item(s) available in stock.');
    }

    // Product already exists in cart.
    if (row['cartItemId'] != null) {
      final updateResult = await conn.execute(
        '''
      UPDATE CartItems
      SET quantity = :quantity
      WHERE id = :id
      ''',
        {'quantity': newQuantity, 'id': row['cartItemId']},
      );

      return updateResult.affectedRows.toInt() > 0;
    }

    // Product does not exist in cart.
    final insertResult = await conn.execute(
      '''
    INSERT INTO CartItems
      (id, productId, userId, quantity)
    VALUES
      (UUID(), :productId, :userId, :quantity)
    ''',
      {'productId': productId, 'userId': userId, 'quantity': quantity},
    );

    return insertResult.affectedRows.toInt() > 0;
  }

  Future<List<CartItem>> getUserCart(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      '''
    SELECT
      id,
      productId,
      userId,
      quantity,
      createdAt
    FROM CartItems
    WHERE userId = :userId
    ORDER BY createdAt DESC
    ''',
      {'userId': userId},
    );

    return result.rows.map((row) => CartItem.fromRow(row.assoc())).toList();
  }

  Future<bool> updateCartQuantity(String cartItemId, int quantity) async {
    final conn = await connection;

    if (quantity <= 0) {
      return deleteCartItem(cartItemId);
    }

    // Make sure the requested quantity does not exceed stock.
    final stockResult = await conn.execute(
      '''
    SELECT p.quantity AS stockQuantity
    FROM CartItems c
    INNER JOIN Products p
      ON p.id = c.productId
    WHERE c.id = :cartItemId
    ''',
      {'cartItemId': cartItemId},
    );

    if (stockResult.rows.isEmpty) {
      return false;
    }

    final stockQuantity =
        int.tryParse(stockResult.rows.first.assoc()['stockQuantity'] ?? '0') ??
        0;

    if (quantity > stockQuantity) {
      throw Exception('Only $stockQuantity item(s) available in stock.');
    }

    final result = await conn.execute(
      '''
    UPDATE CartItems
    SET quantity = :quantity
    WHERE id = :id
    ''',
      {'quantity': quantity, 'id': cartItemId},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<bool> deleteCartItem(String cartItemId) async {
    final conn = await connection;

    final result = await conn.execute(
      '''
    DELETE FROM CartItems
    WHERE id = :id
    ''',
      {'id': cartItemId},
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<bool> clearUserCart(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      '''
    DELETE FROM CartItems
    WHERE userId = :userId
    ''',
      {'userId': userId},
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
        '''
      INSERT INTO Products (
        id,
        name,
        categoryId,
        price,
        quantity,
        brand,
        badge,
        rating,
        discount,
        description,
        image
      )
      VALUES (
        UUID(),
        :name,
        :categoryId,
        :price,
        :quantity,
        :brand,
        :badge,
        :rating,
        :discount,
        :description,
        :image
      )
      ''',
        {
          'name': name,
          'categoryId': categoryId,
          'price': price,
          'quantity': quantity,
          'brand': brand,
          'badge': badge,
          'rating': rating,
          'discount': discount,
          'description': description,

          // Keep the image as Uint8List.
          // mysql_dart sends this as binary data.
          'image': imageBytes,
        },
      );

      return result.affectedRows.toInt() > 0;
    } catch (e) {
      debugPrint('CREATE PRODUCT ERROR: $e');

      throw Exception('Failed to create product: $e');
    }
  }

  Future<List<Product>> getProducts() async {
  final conn = await connection;

  final result = await conn.execute(
    '''
    SELECT
      p.id,
      p.name,
      p.categoryId,
      p.price,
      p.quantity,
      p.brand,
      p.badge,
      p.rating,
      p.discount,
      p.description,
      p.createdAt,
      c.name AS categoryName
    FROM Products p
    LEFT JOIN Categories c ON c.id = p.categoryId
    ORDER BY p.createdAt DESC
    ''',
  );

  return result.rows.map((row) => Product.fromRow(row.assoc())).toList();
}

  Future<List<Category>> fetchCategories() async {
    final conn = await connection;
    final results = await conn.execute(
      "SELECT id, name FROM Categories ORDER BY name ASC",
    );

    return results.rows.map((row) {
      final data = row.assoc();
      return Category(id: data['id'] ?? '', name: data['name'] ?? '');
    }).toList();
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

    debugPrint('IMAGE QUERY START: $productId');

    try {
      final result = await conn.execute(
        '''
      SELECT image
      FROM Products
      WHERE id = :id
      ''',
        {'id': productId},
      );

      debugPrint(
        'IMAGE QUERY FINISHED: $productId '
        'rows=${result.rows.length}',
      );

      if (result.rows.isEmpty) {
        debugPrint('IMAGE NOT FOUND: $productId');
        return null;
      }

      final row = result.rows.first;

      final imageBytes = row.typedColByName<Uint8List>('image');

      if (imageBytes == null || imageBytes.isEmpty) {
        debugPrint('IMAGE EMPTY: $productId');
        return null;
      }

      debugPrint(
        'IMAGE LOADED: $productId '
        '${imageBytes.length} bytes',
      );

      debugPrint(
        'IMAGE FIRST BYTES: '
        '${imageBytes.take(10).toList()}',
      );

      return imageBytes;
    } catch (e, stackTrace) {
      debugPrint('IMAGE QUERY ERROR: $productId');
      debugPrint('$e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Future<List<Product>> fetchProductsPaginated({
    required int offset,
    required int limit,
  }) async {
    final conn = await connection;

    debugPrint('PRODUCT QUERY START: offset=$offset limit=$limit');

    final result = await conn.execute(
      '''
    SELECT
      id,
      name,
      categoryId,
      price,
      quantity,
      brand,
      badge,
      rating,
      discount,
      description,
      createdAt,
      image
    FROM Products
    ORDER BY createdAt DESC
    LIMIT :limit OFFSET :offset
    ''',
      {'limit': limit, 'offset': offset},
    );

    debugPrint('PRODUCT QUERY FINISHED: rows=${result.rows.length}');

    final products = result.rows.map((row) {
      final data = row.assoc();

      final rawImage = data['image'];

      debugPrint(
        'PRODUCT IMAGE: '
        'id=${data['id']} '
        'bytes=${rawImage is List
            ? rawImage.length
            : rawImage is Uint8List
            ? rawImage.length
            : rawImage?.toString().length ?? 0}',
      );

      return Product.fromRow(data);
    }).toList();

    debugPrint('PRODUCTS LOADED: ${products.length}');

    return products;
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

    try {
      final result = await conn.execute(
        '''
      UPDATE Products
      SET image = :image
      WHERE id = :id
      ''',
        {'id': productId, 'image': imageBytes},
      );

      if (result.affectedRows.toInt() == 0) {
        throw Exception(
          "Failed to upload image. "
          "Product ID '$productId' does not exist.",
        );
      }

      return true;
    } catch (e) {
      debugPrint('UPDATE PRODUCT IMAGE ERROR: $e');

      rethrow;
    }
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

  // ===========================================================================
  // PRODUCT REVIEWS
  // ===========================================================================

  Future<bool> addProductReview({
    required String productId,
    required String userId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }

    final conn = await connection;

    final productResult = await conn.execute(
      '''
      SELECT id
      FROM Products
      WHERE id = :productId
      ''',
      {'productId': productId},
    );

    if (productResult.rows.isEmpty) {
      throw Exception('Product not found.');
    }

    final userResult = await conn.execute(
      '''
      SELECT id
      FROM Users
      WHERE id = :userId
      ''',
      {'userId': userId},
    );

    if (userResult.rows.isEmpty) {
      throw Exception('User not found.');
    }

    final result = await conn.execute(
      '''
      INSERT INTO productReviews (
        id,
        productId,
        userId,
        rating,
        comment
      )
      VALUES (
        UUID(),
        :productId,
        :userId,
        :rating,
        :comment
      )
      ''',
      {
        'productId': productId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
      },
    );

    return result.affectedRows.toInt() > 0;
  }

  Future<List<Map<String, String?>>> getProductReviews(
    String productId,
  ) async {
    final conn = await connection;

    final result = await conn.execute(
      '''
      SELECT
        pr.id,
        pr.userId,
        pr.rating,
        pr.comment,
        pr.createdAt
      FROM productReviews pr
      WHERE pr.productId = :productId
      ORDER BY pr.createdAt DESC
      ''',
      {
        'productId': productId,
      },
    );

    return result.rows.map((row) {
      return {
        'id': row.colAt(0)?.toString(),
        'userId': row.colAt(1)?.toString(),
        'rating': row.colAt(2)?.toString(),
        'comment': row.colAt(3)?.toString(),
        'createdAt': row.colAt(4)?.toString(),
      };
    }).toList();
  }

  // ===========================================================================
  // CATEGORIES
  // ===========================================================================

  /// Fetch all categories with the number of products in each category
  Future<List<Map<String, dynamic>>> getCategoriesWithProductCount() async {
    final conn = await connection;

    final result = await conn.execute('''
    SELECT 
        c.id,
        c.name AS category,
        COUNT(p.id) AS product_count
    FROM Categories c
    LEFT JOIN Products p 
        ON p.categoryId = c.id
    GROUP BY c.id, c.name
    ORDER BY c.name
  ''');

    return result.rows.map((row) {
      final data = row.assoc();

      return {
        'id': data['id'],
        'name': data['category'],
        'count': int.tryParse(data['product_count'] ?? '0') ?? 0,
      };
    }).toList();
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
  // OTHER UTILITIES
  // ===========================================================================
  // Existing connection getter/method assumed in your class
  // Future<MySqlConnection> get connection => ...;

  /// Creates and persists a new 6-digit OTP for a user with a default 10-minute expiry
  Future<String?> createOTP({
    required String userId,
    required String code,
    int expiryMinutes = 4,
  }) async {
    final conn = await connection;

    final result = await conn.execute(
      '''
      INSERT INTO userOTPs (id, userId, code, isUsed, createdAt, expiresAt)
      VALUES (
        UUID(), 
        :userId, 
        :code, 
        0, 
        CURRENT_TIMESTAMP, 
        DATE_ADD(CURRENT_TIMESTAMP, INTERVAL :expiryMinutes MINUTE)
      )
      ''',
      {"userId": userId, "code": code, "expiryMinutes": expiryMinutes},
    );

    if (result.affectedRows.toInt() > 0) {
      // Retrieve the generated UUID for lookup/tracking
      final row = await conn.execute(
        "SELECT id FROM userOTPs WHERE userId = :userId AND code = :code ORDER BY createdAt DESC LIMIT 1",
        {"userId": userId, "code": code},
      );
      return row.rows.first.assoc()['id'] as String?;
    }

    return null;
  }

  /// Verifies an OTP using otpId and userId.
  /// Marks it as used and deletes the record upon successful match.
  Future<bool> verifyOTP({
    required String otpId,
    required String userId,
    required String inputCode,
  }) async {
    final conn = await connection;

    // 1. Fetch valid, unexpired, and unused OTP record
    final result = await conn.execute(
      '''
      SELECT code, isUsed, expiresAt 
      FROM userOTPs 
      WHERE id = :otpId 
        AND userId = :userId 
        AND isUsed = 0 
        AND expiresAt > CURRENT_TIMESTAMP
      ''',
      {"otpId": otpId, "userId": userId},
    );

    if (result.rows.isEmpty) {
      // OTP does not exist, is expired, or was already used
      return false;
    }

    final storedCode = result.rows.first.assoc()['code'] as String;

    // 2. Compare user input against stored code
    if (storedCode != inputCode) {
      return false;
    }

    // 3. Mark as used and delete the record
    await conn.execute("UPDATE userOTPs SET isUsed = 1 WHERE id = :otpId", {
      "otpId": otpId,
    });

    await conn.execute("DELETE FROM userOTPs WHERE id = :otpId", {
      "otpId": otpId,
    });

    return true;
  }

  /// Updates an existing OTP record with a new code and resets its expiration duration.
  ///
  /// Automatically updates [createdAt] to CURRENT_TIMESTAMP and calculates
  /// [expiresAt] based on [expiryMinutes].
  Future<bool> updateUserOtp({
    required String otpId,
    required String newOtp,
    int expiryMinutes = 4,
  }) async {
    final conn = await connection;

    try {
      final result = await conn.execute(
        '''
        UPDATE userOTPs 
        SET code = :newOtp,
            isUsed = 0,
            createdAt = CURRENT_TIMESTAMP,
            expiresAt = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL :expiryMinutes MINUTE)
        WHERE id = :otpId
        ''',
        {"newOtp": newOtp, "otpId": otpId, "expiryMinutes": expiryMinutes},
      );

      if (result.affectedRows.toInt() == 0) {
        throw Exception("OTP record not found for the provided ID.");
      }

      return true;
    } catch (e) {
      throw Exception("Failed to update user OTP: ${e.toString()}");
    }
  }

  // ===========================================================================
  // DISPOSAL AND CONNECTION MANAGEMENT
  // ===========================================================================

  Future<void> _closeConnection() async {
    if (_connection != null && _connection!.connected) {
      try {
        await _connection!.close();
      } catch (e) {
        log("Error closing connection: $e");
      }
      _connection = null;
    }
  }

  // ORDERS & CHECKOUT

  Future<Map<String, dynamic>> getCheckoutItems({
    required String userId,
    required List<String> cartItemIds,
  }) async {
    if (cartItemIds.isEmpty) {
      throw Exception('No items selected for checkout.');
    }

    final conn = await connection;

    final placeholders = List.generate(
      cartItemIds.length,
      (index) => ':cartId$index',
    ).join(', ');

    final params = <String, dynamic>{'userId': userId};

    for (int i = 0; i < cartItemIds.length; i++) {
      params['cartId$i'] = cartItemIds[i];
    }

    final result = await conn.execute('''
    SELECT
      c.id AS cartItemId,
      c.productId,
      c.quantity AS cartQuantity,

      p.name,
      p.price,
      p.quantity AS stockQuantity,
      p.discount,
      p.description

    FROM CartItems c

    INNER JOIN Products p
      ON p.id = c.productId

    WHERE c.userId = :userId
      AND c.id IN ($placeholders)

    ORDER BY c.createdAt DESC
    ''', params);

    return {'rows': result.rows};
  }

  Future<String> createOrder({
    required String userId,
    required List<String> cartItemIds,
    required String shippingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    if (cartItemIds.isEmpty) {
      throw Exception('No items selected for checkout.');
    }

    final conn = await connection;

    try {
      // ------------------------------------------------------------
      // START TRANSACTION
      // ------------------------------------------------------------
      await conn.execute('START TRANSACTION');

      final placeholders = List.generate(
        cartItemIds.length,
        (index) => ':cartId$index',
      ).join(', ');

      final params = <String, dynamic>{'userId': userId};

      for (int i = 0; i < cartItemIds.length; i++) {
        params['cartId$i'] = cartItemIds[i];
      }

      // ------------------------------------------------------------
      // GET SELECTED CART ITEMS + CURRENT PRODUCT PRICES/STOCK
      // ------------------------------------------------------------
      final cartResult = await conn.execute('''
      SELECT
        c.id AS cartItemId,
        c.productId,
        c.quantity AS cartQuantity,

        p.price,
        p.quantity AS stockQuantity,
        p.discount

      FROM CartItems c

      INNER JOIN Products p
        ON p.id = c.productId

      WHERE c.userId = :userId
        AND c.id IN ($placeholders)
      ''', params);

      if (cartResult.rows.isEmpty) {
        throw Exception('The selected cart items could not be found.');
      }

      // Make sure every selected cart item still exists.
      if (cartResult.rows.length != cartItemIds.length) {
        throw Exception(
          'One or more selected cart items are no longer available.',
        );
      }

      double subtotal = 0.0;
      double totalDiscount = 0.0;

      final orderItems = <Map<String, dynamic>>[];

      // ------------------------------------------------------------
      // VALIDATE STOCK + CALCULATE TOTALS
      // ------------------------------------------------------------
      for (final row in cartResult.rows) {
        final data = row.assoc();

        final cartItemId = data['cartItemId'] ?? '';
        final productId = data['productId'] ?? '';

        final quantity = int.tryParse(data['cartQuantity'] ?? '0') ?? 0;

        final stockQuantity = int.tryParse(data['stockQuantity'] ?? '0') ?? 0;

        final unitPrice = double.tryParse(data['price'] ?? '0') ?? 0.0;

        final discountPercentage =
            double.tryParse(data['discount'] ?? '0') ?? 0.0;

        if (quantity <= 0) {
          throw Exception('Invalid quantity for product $productId.');
        }

        if (stockQuantity <= 0) {
          throw Exception('One of the selected products is out of stock.');
        }

        if (quantity > stockQuantity) {
          throw Exception(
            'Only $stockQuantity item(s) remain in stock for one of your selected products.',
          );
        }

        final itemSubtotal = unitPrice * quantity;

        final itemDiscount = itemSubtotal * (discountPercentage / 100);

        final itemTotal = itemSubtotal - itemDiscount;

        subtotal += itemSubtotal;
        totalDiscount += itemDiscount;

        orderItems.add({
          'cartItemId': cartItemId,
          'productId': productId,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'discount': itemDiscount,
          'totalPrice': itemTotal,
        });
      }

      // ------------------------------------------------------------
      // SHIPPING
      // ------------------------------------------------------------
      //
      // Your current cart implementation uses a delivery fee of 0
      // because the actual business rule has not been defined yet.
      //
      const double shippingFee = 0.0;

      final totalAmount = subtotal - totalDiscount + shippingFee;

      // ------------------------------------------------------------
      // GENERATE ORDER ID
      // ------------------------------------------------------------
      // final uuidResult = await conn.execute('SELECT UUID() AS orderId');

      // if (uuidResult.rows.isEmpty) {
      //   throw Exception('Unable to generate order ID.');
      // }

      // final orderId = uuidResult.rows.first.assoc()['orderId'] ?? '';

      // if (orderId.isEmpty) {
      //   throw Exception('Unable to generate order ID.');
      // }

      // ------------------------------------------------------------
      // GENERATE ORDER ID
      // ------------------------------------------------------------
      final currentYear = DateTime.now().year;
      final random = math.Random();

      String orderId;

      while (true) {
        final randomNumber = 100000 + random.nextInt(900000);

        orderId = 'ORD-$currentYear-$randomNumber';

        // Make sure the generated ID does not already exist.
        final existingOrder = await conn.execute(
          '''
    SELECT id
    FROM Orders
    WHERE id = :orderId
    LIMIT 1
    ''',
          {'orderId': orderId},
        );

        if (existingOrder.rows.isEmpty) {
          break;
        }
      }
      // ------------------------------------------------------------
      // CREATE ORDER
      // ------------------------------------------------------------
      await conn.execute(
        '''
      INSERT INTO Orders (
        id,
        userId,
        status,
        totalAmount,
        subTotal,
        discount,
        shippingFee,
        paymentMethod,
        shippingAddress,
        notes
      )
      VALUES (
        :id,
        :userId,
        'pending',
        :totalAmount,
        :subTotal,
        :discount,
        :shippingFee,
        :paymentMethod,
        :shippingAddress,
        :notes
      )
      ''',
        {
          'id': orderId,
          'userId': userId,
          'totalAmount': totalAmount,
          'subTotal': subtotal,
          'discount': totalDiscount,
          'shippingFee': shippingFee,
          'paymentMethod': paymentMethod,
          'shippingAddress': shippingAddress,
          'notes': notes,
        },
      );

      // ------------------------------------------------------------
      // CREATE ORDER ITEMS + REDUCE STOCK
      // ------------------------------------------------------------
      for (final item in orderItems) {
        await conn.execute(
          '''
        INSERT INTO OrderItems (
          id,
          orderId,
          productId,
          quantity,
          unitPrice,
          discount,
          totalPrice
        )
        VALUES (
          UUID(),
          :orderId,
          :productId,
          :quantity,
          :unitPrice,
          :discount,
          :totalPrice
        )
        ''',
          {
            'orderId': orderId,
            'productId': item['productId'],
            'quantity': item['quantity'],
            'unitPrice': item['unitPrice'],
            'discount': item['discount'],
            'totalPrice': item['totalPrice'],
          },
        );

        // Re-check stock while reducing it.
        final stockUpdate = await conn.execute(
          '''
        UPDATE Products
        SET quantity = quantity - :quantity
        WHERE id = :productId
          AND quantity >= :quantity
        ''',
          {'productId': item['productId'], 'quantity': item['quantity']},
        );

        if (stockUpdate.affectedRows.toInt() == 0) {
          throw Exception(
            'Stock changed while placing your order. Please try again.',
          );
        }
      }

      // ------------------------------------------------------------
      // REMOVE ONLY PURCHASED CART ITEMS
      // ------------------------------------------------------------
      final deleteParams = <String, dynamic>{'userId': userId};

      for (int i = 0; i < cartItemIds.length; i++) {
        deleteParams['deleteCartId$i'] = cartItemIds[i];
      }

      final deletePlaceholders = List.generate(
        cartItemIds.length,
        (index) => ':deleteCartId$index',
      ).join(', ');

      await conn.execute('''
      DELETE FROM CartItems
      WHERE userId = :userId
        AND id IN ($deletePlaceholders)
      ''', deleteParams);

      // ------------------------------------------------------------
      // COMMIT
      // ------------------------------------------------------------
      await conn.execute('COMMIT');

      return orderId;
    } catch (e) {
      // ------------------------------------------------------------
      // ROLLBACK EVERYTHING
      // ------------------------------------------------------------
      try {
        await conn.execute('ROLLBACK');
      } catch (_) {
        // Ignore rollback failure and preserve original exception.
      }

      throw Exception('Failed to place order: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final conn = await connection;

    final result = await conn.execute(
      '''
    SELECT
      o.id,
      o.status,
      o.totalAmount,
      o.subTotal,
      o.discount,
      o.shippingFee,
      o.paymentMethod,
      o.shippingAddress,
      o.createdAt,
      o.updatedAt,
      COUNT(oi.id) AS itemsCount,
      MIN(oi.productId) AS productId
    FROM Orders o
    LEFT JOIN OrderItems oi
      ON oi.orderId = o.id
    WHERE o.userId = :userId
    GROUP BY
      o.id,
      o.status,
      o.totalAmount,
      o.subTotal,
      o.discount,
      o.shippingFee,
      o.paymentMethod,
      o.shippingAddress,
      o.createdAt,
      o.updatedAt
    ORDER BY o.createdAt DESC
    ''',
      {'userId': userId},
    );

    return result.rows.map((row) => row.assoc()).toList();
  }

Future<void> updateOrderStatus({
  required String orderId,
  required String status,
}) async {
  final conn = await connection;

  // Get the customer who owns this order.
  final orderResult = await conn.execute(
    '''
    SELECT userId
    FROM Orders
    WHERE id = :orderId
    ''',
    {
      'orderId': orderId,
    },
  );

  if (orderResult.rows.isEmpty) {
    throw Exception('Order not found.');
  }

  final orderData = orderResult.rows.first.assoc();
  final userId = orderData['userId'];

  if (userId == null || userId.isEmpty) {
    throw Exception('This order has no associated user.');
  }

  // Update the order status.
  final updateResult = await conn.execute(
    '''
    UPDATE Orders
    SET status = :status
    WHERE id = :orderId
    ''',
    {
      'orderId': orderId,
      'status': status,
    },
  );

  if (updateResult.affectedRows.toInt() == 0) {
    throw Exception('Order status was not updated.');
  }

  // Create notification message.
  String title;
  String message;

  switch (status) {
    case 'processing':
      title = 'Order Processing';
      message =
          'Your order #$orderId is now being processed.';
      break;

    case 'shipped':
      title = 'Order Shipped';
      message =
          'Your order #$orderId has been shipped and is on its way.';
      break;

    case 'out_for_delivery':
      title = 'Out for Delivery';
      message =
          'Your order #$orderId is out for delivery.';
      break;

    case 'delivered':
      title = 'Order Delivered';
      message =
          'Your order #$orderId has been delivered successfully.';
      break;

    case 'pending':
      title = 'Order Pending';
      message =
          'Your order #$orderId is currently pending.';
      break;

    default:
      title = 'Order Status Updated';
      message =
          'The status of your order #$orderId has been updated to $status.';
  }

  // Save notification.
  await conn.execute(
    '''
    INSERT INTO Notifications (
      id,
      userId,
      orderId,
      title,
      message,
      type,
      isRead
    )
    VALUES (
      UUID(),
      :userId,
      :orderId,
      :title,
      :message,
      'order_status',
      FALSE
    )
    ''',
    {
      'userId': userId,
      'orderId': orderId,
      'title': title,
      'message': message,
    },
  );
}

Future<List<Map<String, dynamic>>> getUserNotifications(
  String userId,
) async {
  final conn = await connection;

  final result = await conn.execute(
    '''
    SELECT
      id,
      userId,
      orderId,
      title,
      message,
      type,
      isRead,
      createdAt
    FROM Notifications
    WHERE userId = :userId
    ORDER BY createdAt DESC
    ''',
    {
      'userId': userId,
    },
  );

  return result.rows.map((row) => row.assoc()).toList();
}

Future<int> getUnreadNotificationCount(String userId) async {
  final conn = await connection;

  final result = await conn.execute(
    '''
    SELECT COUNT(*) AS unreadCount
    FROM Notifications
    WHERE userId = :userId
      AND isRead = FALSE
    ''',
    {
      'userId': userId,
    },
  );

  if (result.rows.isEmpty) {
    return 0;
  }

  final data = result.rows.first.assoc();

  return int.tryParse(data['unreadCount'] ?? '0') ?? 0;
}

Future<void> markNotificationAsRead(
  String notificationId,
) async {
  final conn = await connection;

  await conn.execute(
    '''
    UPDATE Notifications
    SET isRead = TRUE
    WHERE id = :notificationId
    ''',
    {
      'notificationId': notificationId,
    },
  );
}

Future<void> markAllNotificationsAsRead(
  String userId,
) async {
  final conn = await connection;

  await conn.execute(
    '''
    UPDATE Notifications
    SET isRead = TRUE
    WHERE userId = :userId
      AND isRead = FALSE
    ''',
    {
      'userId': userId,
    },
  );
}

Future<void> submitUserSupport({
  required String userId,
  required String category,
  required String subject,
  required String message,
}) async {
  final conn = await connection;

  await conn.execute(
    '''
    INSERT INTO UserSupport (
      id,
      userId,
      category,
      subject,
      message,
      status
    )
    VALUES (
      UUID(),
      :userId,
      :category,
      :subject,
      :message,
      'open'
    )
    ''',
    {
      'userId': userId,
      'category': category,
      'subject': subject,
      'message': message,
    },
  );
}

Future<List<Map<String, dynamic>>> getUserSupportRequests(
  String userId,
) async {
  final conn = await connection;

  final result = await conn.execute(
    '''
    SELECT
      id,
      userId,
      category,
      subject,
      message,
      status,
      adminResponse,
      createdAt,
      updatedAt
    FROM UserSupport
    WHERE userId = :userId
    ORDER BY createdAt DESC
    ''',
    {
      'userId': userId,
    },
  );

  return result.rows.map((row) => row.assoc()).toList();
}

Future<List<Map<String, dynamic>>> getAllUserSupportRequests() async {
  final conn = await connection;

  final result = await conn.execute(
    '''
    SELECT
      s.id,
      s.userId,
      s.category,
      s.subject,
      s.message,
      s.status,
      s.adminResponse,
      s.createdAt,
      s.updatedAt,
      u.fullName,
      u.email
    FROM UserSupport s
    INNER JOIN Users u
      ON s.userId = u.id
    ORDER BY s.createdAt DESC
    ''',
  );

  return result.rows.map((row) => row.assoc()).toList();
}

Future<void> updateSupportRequestStatus({
  required String supportId,
  required String status,
  String? adminResponse,
}) async {
  final conn = await connection;

  // 1. Get the user who submitted the support request.
  final supportResult = await conn.execute(
    '''
    SELECT
      userId,
      subject
    FROM UserSupport
    WHERE id = :supportId
    ''',
    {
      'supportId': supportId,
    },
  );

  if (supportResult.rows.isEmpty) {
    throw Exception('Support request not found.');
  }

  final supportData = supportResult.rows.first.assoc();

  final userId = supportData['userId'];
  final subject = supportData['subject'] ?? 'Support Request';

  if (userId == null || userId.isEmpty) {
    throw Exception(
      'This support request has no associated user.',
    );
  }

  // 2. Update the support request.
  final updateResult = await conn.execute(
    '''
    UPDATE UserSupport
    SET
      status = :status,
      adminResponse = :adminResponse
    WHERE id = :supportId
    ''',
    {
      'supportId': supportId,
      'status': status,
      'adminResponse': adminResponse,
    },
  );

  if (updateResult.affectedRows.toInt() == 0) {
    throw Exception(
      'Support request was not updated.',
    );
  }

  // 3. Only notify the user when the admin actually
  //    provided a response.
  if (adminResponse != null &&
      adminResponse.trim().isNotEmpty) {
    String title;
    String message;

    switch (status) {
      case 'in_progress':
        title = 'Support Request Updated';
        message =
            'An admin has responded to your support request '
            '"$subject". Your request is now in progress.';
        break;

      case 'resolved':
        title = 'Support Request Resolved';
        message =
            'An admin has responded to your support request '
            '"$subject". Your request has been marked as resolved.';
        break;

      case 'closed':
        title = 'Support Request Closed';
        message =
            'An admin has responded to your support request '
            '"$subject". Your support request has been closed.';
        break;

      case 'open':
      default:
        title = 'Support Request Updated';
        message =
            'An admin has responded to your support request '
            '"$subject".';
        break;
    }

    // 4. Create a notification for the user.
    await conn.execute(
      '''
      INSERT INTO Notifications (
        id,
        userId,
        orderId,
        title,
        message,
        type,
        isRead
      )
      VALUES (
        UUID(),
        :userId,
        NULL,
        :title,
        :message,
        'support',
        FALSE
      )
      ''',
      {
        'userId': userId,
        'title': title,
        'message': message,
      },
    );
  }
}





  Future<void> dispose() async {
    _idleTimer?.cancel();
    await _closeConnection();
  }
}
