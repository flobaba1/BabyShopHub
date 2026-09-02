import 'package:mysql_client/mysql_client.dart';
import 'package:baby_shop_hub/utilities/models/product.dart';

class MySQLService {
  static final MySQLService _instance = MySQLService._internal();
  MySQLConnection? _connection;

  factory MySQLService() => _instance;
  MySQLService._internal();

  Future<MySQLConnection> get connection async {
    if (_connection != null && _connection!.connected) {
      return _connection!;
    }
    _connection = await MySQLConnection.createConnection(
      host: "YOUR_MYSQL_SERVER_IP", // Use 10.0.2.2 for Android local host
      port: 3306,
      userName: "app_user",
      password: "secure_password",
      databaseName: "baby_shop_db",
    );
    await _connection!.connect();
    return _connection!;
  }

  // Paginated SQL Query Execution
  Future<List<Product>> fetchProductsPaginated({
    required int offset,
    required int limit,
  }) async {
    final conn = await connection;
    final result = await conn.execute(
      "SELECT id, name, brand, price, image_url, badge_text FROM products LIMIT :limit OFFSET :offset",
      {"limit": limit, "offset": offset},
    );

    List<Product> products = [];
    for (final row in result.rows) {
      products.add(Product.fromRow(row.assoc()));
    }
    return products;
  }
}
