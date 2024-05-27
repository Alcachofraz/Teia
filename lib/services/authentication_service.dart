import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:teia/services/firebase/firestore_utils.dart';
import 'package:teia/services/user_management_service.dart';
import 'package:teia/models/user.dart' as u;

class AuthResponse {
  final String message;
  final bool success;

  AuthResponse(this.message, this.success);
}

class AuthenticationService extends GetxService {
  u.User? get user => _user;

  static u.User? _user;

  static AuthenticationService get value => Get.put(AuthenticationService());
  final UserManagementService userManagementService =
      Get.put(UserManagementService());

  Stream<bool> authStateChanges =
      FirebaseUtils.auth.authStateChanges().asyncMap((User? fUser) async {
    if (fUser != null) {
      _user = await UserManagementService.value.userGet(fUser.uid);
    }
    return fUser != null;
  });

  Future<AuthResponse> login(String email, String password) async {
    try {
      final credential = await FirebaseUtils.auth
          .signInWithEmailAndPassword(email: email, password: password);
      final fUser = credential.user;
      if (fUser == null) return AuthResponse('An error occurred', false);
      _user = await userManagementService.userGet(fUser.uid);
      return AuthResponse('Success', true);
    } on FirebaseAuthException catch (e) {
      return AuthResponse(e.message.toString(), false);
    }
  }

  Future<AuthResponse> register(String email, String password) async {
    try {
      return await FirebaseUtils.firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then<AuthResponse>((value) async {
        if (value.docs.isNotEmpty) {
          return AuthResponse('A user with that email already exists', false);
        } else {
          UserCredential userCredential = await FirebaseUtils.auth
              .createUserWithEmailAndPassword(email: email, password: password);
          if (userCredential.user == null) {
            return AuthResponse('An error occurred', false);
          }
          _user = await userManagementService.userGet(userCredential.user!.uid);
          await userManagementService.createUser(userCredential.user!);
          return AuthResponse('Success', true);
        }
      });
    } on FirebaseAuthException catch (e) {
      return AuthResponse(e.message.toString(), false);
    } on Exception catch (e) {
      return AuthResponse(e.toString(), false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseUtils.auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await FirebaseUtils.auth.signOut();
  }
}
