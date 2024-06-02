import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/firebase/firestore_utils.dart';
import 'package:teia/services/story_management_service.dart';
import 'package:teia/utils/utils.dart';

class GroupManagementService extends GetxService {
  static GroupManagementService get value => Get.put(GroupManagementService());

  // Get group by name
  Future<Group> groupGet(String name) async {
    final query =
        await FirebaseUtils.firestore.collection('groups').doc(name).get();
    Map<String, dynamic> data = query.data() ?? {};
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
        .where('users', arrayContains: AuthenticationService.value.uid)
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
    await FirebaseUtils.firestore.collection('groups').doc(name).set(
          Group.init(
            name,
            password,
            AuthenticationService.value.uid,
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

  // Get next available avatar based on given userState
  int nextAvatar(Map<String, dynamic> userState) {
    int avatar = 0;
    while (userState.values.any((element) => element['avatar'] == avatar)) {
      avatar++;
    }
    return avatar;
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
    final users = group.data()['users'] as List<String>;
    final userState = group.data()['userState'] as Map<String, dynamic>;
    if (users.contains(AuthenticationService.value.uid)) {
      throw Exception('You are already in this group');
    }
    users.add(AuthenticationService.value.uid!);
    userState[AuthenticationService.value.uid!] = UserState(
      role: Role.reader,
      ready: false,
      avatar: nextAvatar(userState),
      name: Utils.getUsernameFromEmail(AuthenticationService.value.user.email!),
      uid: AuthenticationService.value.uid!,
      admin: false,
    ).toMap();
    await group.reference.update(
      {
        'users': users,
        'userState': userState,
      },
    );
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

  // Change role of user in group
  Future<void> changeRole(String groupName, Role role) async {
    await FirebaseUtils.firestore.collection('groups').doc(groupName).set(
      {
        "userState": {
          AuthenticationService.value.user.uid: {
            "role": role.index,
          }
        }
      },
      SetOptions(merge: true),
    );
  }

  // Stream to listen for group changes
  Stream<Group> groupStream(String groupName) {
    return FirebaseUtils.firestore
        .collection('groups')
        .doc(groupName)
        .snapshots()
        .asyncMap(
          (event) async => Group.fromMap(
            event.data()!,
            await Get.put(StoryManagementService()).storyGet(
              event.data()!['story'],
            ),
          ),
        );
  }

  Future<void> updateUser(
      String groupName, int avatar, String name, Role role) async {
    await FirebaseUtils.firestore.collection('groups').doc(groupName).set(
      {
        'userState': {
          AuthenticationService.value.uid: {
            'avatar': avatar,
            'name': name,
            'role': role.index,
          }
        }
      },
      SetOptions(merge: true),
    );
  }
}
