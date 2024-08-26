import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/screens/group/widgets/group_status_box.dart';
import 'package:teia/screens/group/widgets/story_box.dart';
import 'package:teia/screens/group/widgets/users_box.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/group_management_service.dart';
import 'package:teia/views/teia_button.dart';

class WriterGroupScreen extends StatelessWidget {
  WriterGroupScreen({super.key, required this.controller});

  final GroupController controller;

  final Color color = ArtService.value.pastel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 1000,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                          loadingRole: controller.loadingRole.value,
                          group: controller.group.value!,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StoryBox(
                            story: controller.group.value!.story,
                          ),
                          const Gap(12),
                          TeiaButton(
                            text: 'Chapter Editor',
                            color: color,
                            widget: const Icon(
                              Icons.schema_outlined,
                              color: Colors.white,
                            ),
                            onTap: () {
                              Get.toNamed('/chapter_editor', parameters: {
                                'storyId': controller.group.value!.story!.id,
                                'chapterId':
                                    (controller.group.value!.currentChapter)
                                        .toString(),
                                'group': controller.group.value!.name,
                              });
                            },
                          ),
                          const Gap(16),
                          GroupStatusBox(
                            group: controller.group.value!,
                            color: color,
                          ),
                          if (controller.group.value!.state ==
                              GroupState.writing)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(24),
                                const Divider(),
                                const Gap(4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(
                                      () => Checkbox(
                                        value: controller
                                            .group.value!.finalChapter,
                                        onChanged: (bool? value) =>
                                            GroupManagementService.value
                                                .setFinalChapter(
                                                    controller
                                                        .group.value!.name,
                                                    value ?? false),
                                      ),
                                    ),
                                    const Text('Final Chapter'),
                                  ],
                                ),
                                const Gap(8),
                                TeiaButton(
                                  color: color,
                                  onTap: () {
                                    GroupManagementService.value.setWriterReady(
                                        controller.group.value!);
                                  },
                                  text:
                                      '(${controller.group.value!.userState.entries.where((e) => e.value.role == Role.writer && e.value.ready).length} / ${controller.group.value!.userState.entries.where((e) => e.value.role == Role.writer).length})  Finish',
                                  expand: false,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
