import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:teia/screens/auth/controller/auth_controller.dart';
import 'package:teia/views/misc/rounded_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.goToLogin});
  final void Function() goToLogin;
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                  TextField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter valid email',
                    ),
                    focusNode: controller.emailFocus,
                    onSubmitted: (_) => controller.passwordFocus.requestFocus(),
                    onChanged: (_) => controller.clearError(),
                  ),
                  const Gap(20),
                  TextField(
                    obscureText: true,
                    controller: controller.passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password',
                    ),
                    focusNode: controller.passwordFocus,
                    onSubmitted: (_) => controller.register(),
                    onChanged: (_) => controller.clearError(),
                  ),
                  const Gap(6),
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
                    text: 'Register',
                    onTap: controller.register,
                    expand: true,
                  ),
                  const Gap(16),
                  RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Login',
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 15),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.goToLogin,
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
