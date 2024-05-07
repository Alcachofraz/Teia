import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/services/group_management_service.dart';

class HomeController extends GetxController {
  RxList<Group> joinedGroups = <Group>[].obs;
  final GroupManagementService groupManagementService =
      Get.put(GroupManagementService());

  @override
  void onInit() {
    refreshJoinedGroups();
    super.onInit();
  }

  Future<void> refreshJoinedGroups() async {
    joinedGroups.value = await groupManagementService.getJoinedGroups();
  }
}
