import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:teia/services/user_management_service.dart';

class AuthGate extends StatelessWidget {
  final StatefulWidget landingScreen;
  const AuthGate({super.key, required this.landingScreen});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInScreen(
            providerConfigs: [
              EmailProviderConfiguration(),
            ],
          );
        }
        UserManagementService.tryCreateUser(snapshot.data!);
        return landingScreen;
      },
    );
  }
}
