import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MYSQL_HOST')
  static const String mysqlHost = _Env.mysqlHost;

  @EnviedField(varName: 'MYSQL_PORT')
  static const int mysqlPort = _Env.mysqlPort;

  @EnviedField(varName: 'MYSQL_USER')
  static const String mysqlUser = _Env.mysqlUser;

  @EnviedField(varName: 'MYSQL_PASSWORD', obfuscate: true)
  static final String mysqlPassword = _Env.mysqlPassword;

  @EnviedField(varName: 'MYSQL_DATABASE')
  static const String mysqlDatabase = _Env.mysqlDatabase;

  @EnviedField(varName: 'EMAILJS_SERVICE_ID')
  static const String emailJsServiceId = _Env.emailJsServiceId;

  @EnviedField(varName: 'EMAILJS_TEMPLATE_OTP_ID')
  static const String emailJsTemplateOtpId = _Env.emailJsTemplateOtpId;

  @EnviedField(varName: 'EMAILJS_TEMPLATE_RESET_PASSWORD_ID')
  static const String emailJsTemplateResetPasswordId =
      _Env.emailJsTemplateResetPasswordId;

  @EnviedField(varName: 'EMAILJS_KEY')
  static const String emailJsKey = _Env.emailJsKey;

  @EnviedField(varName: 'EMAILJS_USER_ID')
  static const String emailJsUserId = _Env.emailJsUserId;

  @EnviedField(varName: 'EMAILJS_PUBLIC_KEY')
  static const String emailJsPublicKey = _Env.emailJsPublicKey;
}
