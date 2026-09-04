
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MYSQL_HOST', obfuscate: true)
  static final String mysqlHost = _Env.mysqlHost;

  @EnviedField(varName: 'MYSQL_PORT')
  static final int mysqlPort = _Env.mysqlPort;

  @EnviedField(varName: 'MYSQL_USER', obfuscate: true)
  static final String mysqlUser = _Env.mysqlUser;

  @EnviedField(varName: 'MYSQL_PASSWORD', obfuscate: true)
  static final String mysqlPassword = _Env.mysqlPassword;

  @EnviedField(varName: 'MYSQL_DATABASE', obfuscate: true)
  static final String mysqlDatabase = _Env.mysqlDatabase;
}