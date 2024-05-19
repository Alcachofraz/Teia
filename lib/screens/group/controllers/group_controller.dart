import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/models/user.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/screens/group/models/user_tile_info.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/group_management_service.dart';
import 'package:teia/services/user_management_service.dart';

class GroupController extends GetxController {
  final GroupManagementService groupManagementService =
      Get.put(GroupManagementService());
  final UserManagementService userManagementService =
      Get.put(UserManagementService());
  final AuthenticationService authenticationService =
      Get.put(AuthenticationService());
  final Rxn<Group> group = Rxn<Group>();
  final RxList<UserTileInfo> userTileInfo = <UserTileInfo>[].obs;

  RxBool loading = false.obs;
  late Color userBoxColor;
  late Color storyBoxColor;

  @override
  void onInit() async {
    loading.value = true;
    userBoxColor = ArtService.value.pastel();
    storyBoxColor = ArtService.value.pastel();
    String groupName = Get.parameters['group'] ?? '';
    if (groupName.isNotEmpty) {
      group.value = await groupManagementService.groupGet(groupName);
      if (group.value != null) {
        for (MapEntry<String, UserState> entry
            in group.value!.userState.entries) {
          User user = await userManagementService.userGet(entry.key);
          userTileInfo.add(
            UserTileInfo(
              user: user,
              isSelf: entry.key == authenticationService.uid,
              avatar: entry.value.avatar,
              ready: entry.value.ready,
              role: entry.value.role,
              color: ArtService.value.pastel(),
            ),
          );
        }
      }
      loading.value = false;
    }

    super.onInit();
  }
}
