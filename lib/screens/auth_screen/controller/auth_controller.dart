import 'package:teia/services/authentication_service.dart';

class AuthController {
  static String email = '';
  static String password = '';

  static Future<void> register(String email, String password) async {
    await AuthenticationService.register(email, password);
  }

  static Future<void> logIn(String email, String password) async {
    await AuthenticationService.login(email, password);
  }

  static Future<void> sendPasswordResetEmail() async {
    await AuthenticationService.sendPasswordResetEmail(email);
  }
}
