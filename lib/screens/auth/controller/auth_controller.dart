import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/services/authentication_service.dart';

class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  RxString error = ''.obs;

  Future<void> register() async {
    AuthResponse res = await AuthenticationService.value
        .register(emailController.text, passwordController.text);
    if (!res.success) {
      error.value = res.message;
    }
  }

  Future<void> logIn() async {
    AuthResponse res = await AuthenticationService.value
        .login(emailController.text, passwordController.text);
    if (!res.success) {
      error.value = res.message;
    }
  }

  Future<void> sendPasswordResetEmail() async {
    await AuthenticationService.value
        .sendPasswordResetEmail(emailController.text);
    Get.snackbar('Password Reset Email Sent', 'Check your email');
  }

  Future<void> logout() async {
    await AuthenticationService.value.logout();
  }

  void clearError() {
    error.value = '';
  }
}
