import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/screens/group/widgets/story_box.dart';
import 'package:teia/screens/group/widgets/story_create_box.dart';
import 'package:teia/screens/group/widgets/users_box.dart';
import 'package:teia/views/teia_button.dart';

class IdleGroupScreen extends StatelessWidget {
  const IdleGroupScreen({super.key, required this.controller});

  final GroupController controller;

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
                    child: Obx(
                      () => Padding(
                        padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                        child: Column(
                          children: [
                            StoryBox(
                              story: controller.group.value!.story,
                            ),
                            const Gap(12),
                            StoryCreateBox(
                              story: controller.group.value!.story,
                              color: controller.storyBoxColor,
                              onCreate: controller.createStory,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TeiaButton(
                  locked: controller.group.value!.story == null ||
                      (controller.group.value!.story!.finished &&
                          controller.group.value!.userState.entries.any(
                              (entry) => entry.value.role == Role.writer)) ||
                      (!controller.group.value!.story!.finished &&
                          !controller.group.value!.userState.entries
                              .any((entry) => entry.value.role == Role.writer)),
                  text: 'Start Story',
                  onTap: controller.startStory,
                ),
              ),
            ),
            const Gap(40),
          ],
        ),
      ),
    );
  }
}
