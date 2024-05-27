import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/screens/group/widgets/story_box.dart';
import 'package:teia/screens/group/widgets/users_box.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/teia_button.dart';

class GroupScreen extends GetView<GroupController> {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GroupController());
    return ScreenWrapper(
      body: Center(
        child: SizedBox(
          width: 1000,
          child: Obx(
            () => controller.loading.value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : controller.allowed.value
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*Obx(
                () => controller.group.value != null &&
                        controller.group.value!.story != null
                    ? Tile(
                        color: Colors.black,
                        onTap: () {
                          Get.toNamed('/chapter_editor', parameters: {
                            'storyId': controller.group.value!.story!.id,
                            'chapterId': '1',
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Chapter Editor',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : Container(),
                                ),*/
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              24,
                              32,
                              24,
                              0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                controller.group.value!.name,
                                style: GoogleFonts.lilitaOne(
                                  fontSize: 32.0,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Obx(
                                      () => UsersBox(
                                        color: controller.userBoxColor,
                                        info: controller.userInfo,
                                        onRoleChanged: controller.onRoleChanged,
                                        onTapEditUser: controller.onTapEditUser,
                                        loadingRole:
                                            controller.loadingRole.value,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 24, 24, 24),
                                    child: StoryBox(
                                      color: controller.storyBoxColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
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
        ),
      ),
    );
  }
}
