import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:teia/screens/auth/controller/auth_controller.dart';
import 'package:teia/views/misc/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.goToRegister});

  final void Function() goToRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    return Row(
      children: [
        Expanded(
          child: Center(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Gap(15),
                  TextFormField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter valid email',
                    ),
                    focusNode: controller.emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) =>
                        controller.passwordFocus.requestFocus(),
                    onChanged: (_) => controller.clearError(),
                  ),
                  const Gap(20),
                  TextFormField(
                    obscureText: true,
                    controller: controller.passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password',
                    ),
                    focusNode: controller.passwordFocus,
                    onFieldSubmitted: (_) => controller.logIn(),
                    onChanged: (_) => controller.clearError(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextButton(
                        onPressed: () {
                          controller.sendPasswordResetEmail();
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const Gap(4),
                  RoundedButton(
                    text: 'Login',
                    expand: true,
                    onTap: controller.logIn,
                  ),
                  const Gap(16),
                  RichText(
                    text: TextSpan(
                      text: 'New User? ',
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Create Account',
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 15),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.goToRegister,
                        ),
                      ],
                    ),
                  ),
                  const Gap(15),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
