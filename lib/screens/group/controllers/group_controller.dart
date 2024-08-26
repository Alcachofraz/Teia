import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/screens/group/models/user_info.dart';
import 'package:teia/screens/group/popups/create_story/create_story.dart';
import 'package:teia/screens/group/popups/edit_user/edit_user.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/group_management_service.dart';
import 'package:teia/services/user_management_service.dart';

class GroupController extends GetxController {
  final GroupManagementService groupManagementService =
      Get.put(GroupManagementService());
  final UserManagementService userManagementService =
      Get.put(UserManagementService());
  final Rxn<Group> group = Rxn<Group>();
  final RxList<UserInfo> userInfo = <UserInfo>[].obs;

  RxBool loading = false.obs;
  late Color userBoxColor;
  late Color storyBoxColor;
  RxBool loadingRole = false.obs;
  RxBool allowed = false.obs;

  RxList<String> avatars = <String>[].obs;

  late PageController pageController;
  late RxInt selectedAvatar = 0.obs;
  late String name;
  late Rx<Role> role = Role.reader.obs;

  final avatarColor = ArtService.value.pastel();
  final nameColor = ArtService.value.pastel();
  final roleColor = ArtService.value.pastel();

  late StreamSubscription<Group> groupSubscription;

  void Function(void Function())? updateGroupScreen;

  @override
  void onInit() async {
    loading.value = true;
    userBoxColor = ArtService.value.pastel();
    storyBoxColor = ArtService.value.pastel();
    String groupName = Get.parameters['group'] ?? '';
    if (groupName.isNotEmpty) {
      groupSubscription = groupManagementService.groupStream(groupName).listen(
        (Group? newGroup) async {
          if (newGroup != null) {
            allowed.value = newGroup.users.contains(
              AuthenticationService.value.uid,
            );
            if (allowed.value) {
              if (newGroup.state != group.value?.state) {
                updateGroupScreen?.call(() {});
              }
              group.value = newGroup;
              userInfo.clear();
              newGroup.userState.forEach((key, value) {
                userInfo.add(UserInfo(
                  isSelf: key == AuthenticationService.value.uid,
                  color: userBoxColor,
                  state: value,
                ));
              });
              userInfo.sort();
            }
          }
          loading.value = false;
        },
      );
    }

    super.onInit();
  }

  @override
  void onClose() {
    groupSubscription.cancel();
    super.onClose();
  }

  Future<void> onRoleChanged(Role? role) async {
    loadingRole.value = true;
    if (role != null && group.value != null) {
      await Get.put(GroupManagementService())
          .changeRole(group.value!.name, role);
    }
    loadingRole.value = false;
  }

  Future<void> onTapEditUser() async {
    avatars.value = ArtService.value.avatarPaths();
    selectedAvatar.value =
        group.value!.userState[AuthenticationService.value.uid]!.avatar;
    pageController = PageController(initialPage: selectedAvatar.value);
    name = group.value!.userState[AuthenticationService.value.uid]!.name;
    role.value = group.value!.userState[AuthenticationService.value.uid]!.role;
    await launchEditUserPopup(Get.context!);
  }

  void previousAvatar() {
    pageController.previousPage(
      duration: 200.milliseconds,
      curve: Curves.decelerate,
    );

    if (selectedAvatar.value > 0) {
      selectedAvatar.value--;
    }
  }

  void nextAvatar() {
    pageController.nextPage(
      duration: 200.milliseconds,
      curve: Curves.decelerate,
    );

    if (selectedAvatar.value < avatars.length - 1) {
      selectedAvatar.value++;
    }
  }

  Future<void> save() async {
    await GroupManagementService.value.updateUser(
      group.value!.name,
      selectedAvatar.value,
      name,
      role.value,
    );
    Get.back();
  }

  Future<void> createStory() async {
    await launchCreateStoryPopup(Get.context!, group.value!.name);
  }

  Future<void> startStory() async {
    await GroupManagementService.value.groupSetWritingState(group.value!.name);
  }

  Future<void> setReaderReady() async {
    await GroupManagementService.value.setReaderReady(group.value!);
    Get.back();
  }

  Future<void> setWriterReady() async {
    await GroupManagementService.value.setWriterReady(group.value!);
    Get.back();
  }
}
