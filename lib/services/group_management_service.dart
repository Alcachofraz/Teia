import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class GroupManagementService {
  Future<void> createGroup(String name, String password) async {
    await FirebaseUtils.firestore.collection('groups').add({
      'name': name,
      'password': password,
      'story': null,
      'users': AuthenticationService.uid == null
          ? []
          : [
              AuthenticationService.uid,
            ],
    });
  }
}
