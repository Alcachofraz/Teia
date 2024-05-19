import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/firebase/firestore_utils.dart';
import 'package:teia/services/story_management_service.dart';

class GroupManagementService extends GetxService {
  AuthenticationService authenticationService =
      Get.put(AuthenticationService());

  // Get group by name
  Future<Group> groupGet(String name) async {
    final query = await FirebaseUtils.firestore
        .collection('groups')
        .where('name', isEqualTo: name)
        .get();
    Map<String, dynamic> data = query.docs.first.data();
    return Group.fromMap(
      data,
      await Get.put(StoryManagementService()).storyGet(
        data['story'],
      ),
    );
  }

  // Get joined groups
  Future<List<Group>> getJoinedGroups() async {
    final query = await FirebaseUtils.firestore
        .collection('groups')
        .where('users', arrayContains: authenticationService.uid)
        .get();
    List<Group> groups = [];
    for (final doc in query.docs) {
      Map<String, dynamic> data = doc.data();
      groups.add(
        Group.fromMap(
          data,
          await Get.put(StoryManagementService()).storyGet(
            data['storyId'],
          ),
        ),
      );
    }
    return groups;
  }

  // Create new group
  Future<void> groupCreate(String name, String password) async {
    await FirebaseUtils.firestore.collection('groups').add(
          Group.init(
            name,
            password,
            authenticationService.uid,
          ).toMap(),
        );
  }

  // Check if group exists
  Future<bool> groupExists(String name) async {
    final query = await FirebaseUtils.firestore
        .collection('groups')
        .where('name', isEqualTo: name)
        .get();
    return query.docs.isNotEmpty;
  }

  // Join existing group
  Future<void> groupJoinExisting(String name, String password) async {
    final query = await FirebaseUtils.firestore
        .collection('groups')
        .where('name', isEqualTo: name)
        .where('password', isEqualTo: password)
        .get();
    if (query.docs.isEmpty) {
      throw Exception('Invalid password');
    }
    final group = query.docs.first;
    final users = group.data()['users'] as List;
    if (users.contains(authenticationService.uid)) {
      throw Exception('You are already in this group');
    }
    users.add(authenticationService.uid);
    await group.reference.update({'users': users});
  }

  // If the group exists, the password is correct and the user is not already in the group, the user is added to the group.
  // If the group does not exist, the group is created and he user joins.
  Future<void> groupJoin(String name, String password) async {
    if (await groupExists(name)) {
      await groupJoinExisting(name, password);
    } else {
      await groupCreate(name, password);
    }
  }
}
