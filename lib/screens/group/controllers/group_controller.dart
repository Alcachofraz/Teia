import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/services/group_management_service.dart';

class GroupController extends GetxController {
  final GroupManagementService groupManagementService =
      Get.put(GroupManagementService());

  final Rxn<Group> group = Rxn<Group>();

  @override
  void onInit() async {
    String groupName = Get.parameters['group'] ?? '';
    if (groupName.isNotEmpty) {
      group.value = await groupManagementService.groupGet(groupName);
    }

    super.onInit();
  }
}
