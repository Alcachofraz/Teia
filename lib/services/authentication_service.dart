import 'package:firebase_auth/firebase_auth.dart';
import 'package:teia/services/firebase/firestore_utils.dart';
import 'package:teia/services/user_management_service.dart';

class AuthenticationService {
  static String? uid = '1';

  static Stream<bool> authStateChanges =
      FirebaseUtils.auth.authStateChanges().map((user) {
    return user != null;
  });

  static Future<String> login(String email, String password) async {
    try {
      final credential = await FirebaseUtils.auth
          .signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) return 'An error occurred';
      return 'Success';
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  static Future<String> register(String email, String password) async {
    return await FirebaseUtils.firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then<String>((value) async {
      if (value.docs.isNotEmpty) {
        return 'A user with that email already exists';
      } else {
        UserCredential userCredential = await FirebaseUtils.auth
            .createUserWithEmailAndPassword(email: email, password: password);
        if (userCredential.user == null) {
          return 'An error occurred';
        }
        await UserManagementService.createUser(userCredential.user!);
        return 'Success';
      }
    });
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseUtils.auth.sendPasswordResetEmail(email: email);
  }
}
