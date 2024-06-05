import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/screens/group/pages/idle_group_screen.dart';
import 'package:teia/screens/group/pages/reader_group_screen.dart';
import 'package:teia/screens/group/pages/writer_group_screen.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/teia_button.dart';

class GroupScreen extends GetView<GroupController> {
  const GroupScreen({super.key});

  Widget _getGroupScreen(GroupController controller) {
    Group group = controller.group.value!;
    if (group.state == GroupState.idle) {
      return IdleGroupScreen(controller: controller);
    } else {
      if (group.userState[AuthenticationService.value.uid]!.role ==
          Role.reader) {
        return ReaderGroupScreen(controller: controller);
      } else {
        return WriterGroupScreen(controller: controller);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(GroupController());
    return ScreenWrapper(
      body: Obx(
        () => controller.loading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : controller.allowed.value
                ? _getGroupScreen(controller)
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'You don\'t have permission to see this page.',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const Gap(20),
                        SizedBox(
                          width: 300,
                          child: TeiaButton(
                            text: 'Go Back',
                            onTap: () => Get.back(),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
