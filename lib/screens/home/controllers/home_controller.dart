import 'dart:math';

import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/group_management_service.dart';

class HomeController extends GetxController {
  RxList<Group> joinedGroups = <Group>[].obs;
  final GroupManagementService groupManagementService =
      Get.put(GroupManagementService());
  late String backgroundLeft;
  late String backgroundRight;
  late BackroundOrientation orientation;

  @override
  void onInit() {
    refreshJoinedGroups();
    backgroundLeft =
        ArtService.value.randomBackgroundPath(BackroundOrientation.left);
    backgroundRight =
        ArtService.value.randomBackgroundPath(BackroundOrientation.right);
    final r = Random();
    orientation = BackroundOrientation
        .values[r.nextInt(BackroundOrientation.values.length)];
    super.onInit();
  }

  Future<void> refreshJoinedGroups() async {
    joinedGroups.value = await groupManagementService.getJoinedGroups();
  }
}
