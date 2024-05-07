import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/services/authentication_service.dart';

class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthenticationService authenticationService = AuthenticationService();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  RxString error = ''.obs;

  Future<void> register() async {
    AuthResponse res = await authenticationService.register(
        emailController.text, passwordController.text);
    if (!res.success) {
      error.value = res.message;
    }
  }

  Future<void> logIn() async {
    AuthResponse res = await authenticationService.login(
        emailController.text, passwordController.text);
    if (!res.success) {
      error.value = res.message;
    }
  }

  Future<void> sendPasswordResetEmail() async {
    await authenticationService.sendPasswordResetEmail(emailController.text);
  }

  Future<void> logout() async {
    await authenticationService.logout();
  }

  void clearError() {
    error.value = '';
  }

  void goToRegister() {
    clearError();
    emailController.clear();
    passwordController.clear();
    Get.toNamed('/register');
  }

  void goToLogin() {
    clearError();
    emailController.clear();
    passwordController.clear();
    Get.toNamed('/login');
  }
}
