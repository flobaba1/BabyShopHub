
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

  @EnviedField(varName: 'EMAILJS_SERVICE_ID', obfuscate: true)
  static final String emailjsServiceId = _Env.emailjsServiceId;

  @EnviedField(varName: 'EMAILJS_PUBLIC_KEY', obfuscate: true)
  static final String emailjsPublicKey = _Env.emailjsPublicKey;

  @EnviedField(varName: 'EMAILJS_KEY', obfuscate: true)
  static final String emailjsPrivateKey = _Env.emailjsPrivateKey;

   @EnviedField(varName: 'EMAILJS_TEMPLATE_OTP_ID', obfuscate: true)
  static final String emailjsOtpTemplateId = _Env.emailjsOtpTemplateId;

   @EnviedField(varName: 'EMAILJS_TEMPLATE_RESET_PASSWORD_ID', obfuscate: true)
  static final String emailjsResetPasswordTemplateId = _Env.emailjsResetPasswordTemplateId;

  @EnviedField(varName: 'EMAILJS_USER_ID', obfuscate: true)
  static final String emailjsUserId = _Env.emailjsUserId;
}