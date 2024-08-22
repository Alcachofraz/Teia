import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/screens/auth/controller/auth_controller.dart';
import 'package:teia/screens/auth/login_screen.dart';
import 'package:teia/screens/auth/register_screen.dart';

class AuthScreen extends GetView<AuthController> {
  AuthScreen({super.key});

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                LoginScreen(
                  goToRegister: () {
                    controller.clearError();
                    controller.emailController.clear();
                    controller.passwordController.clear();
                    pageController.jumpToPage(
                      1,
                    );
                  },
                ),
                RegisterScreen(
                  goToLogin: () {
                    controller.clearError();
                    controller.emailController.clear();
                    controller.passwordController.clear();
                    pageController.jumpToPage(
                      0,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
