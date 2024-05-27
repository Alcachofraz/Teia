import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:teia/models/user.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class UserManagementService extends GetxService {
  static UserManagementService get value => Get.put(UserManagementService());

  /// Try to create user, in case it doesn't exists. If
  /// a user with the same uid already exists, this function
  /// does nothing, and returns false.
  Future<void> createUser(auth.User user) async {
    await FirebaseUtils.firestore.collection('user').doc(user.uid).set(
          User(
            user.uid,
            user.email!.substring(0, user.email!.indexOf('@')),
            user.email!,
          ).toMap(),
        );
  }

  /// Update photo url for user [uid].
  Future<void> userSetPhotoUrl(String uid, String url) async {
    await FirebaseUtils.firestore.collection('user').doc(uid).set({'url': url});
  }

  /// Update name for user [uid].
  Future<void> userSetName(String uid, String name) async {
    await FirebaseUtils.firestore
        .collection('user')
        .doc(uid)
        .set({'name': name});
  }

  /// Get user by [uid].
  Future<User> userGet(String uid) async {
    return User.fromMap(
      (await FirebaseUtils.firestore.collection('user').doc(uid).get()).data()!,
    );
  }
}
