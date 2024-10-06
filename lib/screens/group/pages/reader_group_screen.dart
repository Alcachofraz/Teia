import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/group.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/screens/group/widgets/group_status_box.dart';
import 'package:teia/screens/group/widgets/story_box.dart';
import 'package:teia/screens/group/widgets/users_box.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/views/teia_button.dart';

class ReaderGroupScreen extends StatelessWidget {
  ReaderGroupScreen({super.key, required this.controller});

  final GroupController controller;

  final Color color = ArtService.value.pastel();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Center(
      child: SizedBox(
        width: 1000,
        child: size.width <= size.height
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        children: [
                          StoryBox(
                            story: controller.group.value!.story,
                          ),
                          const Gap(12),
                          Obx(
                            () => controller.group.value!.state ==
                                    GroupState.reading
                                ? TeiaButton(
                                    text: controller
                                            .group
                                            .value!
                                            .userState[AuthenticationService
                                                .value.uid]!
                                            .ready
                                        ? 'You are done with this chapter'
                                        : 'Read chapter',
                                    color: color,
                                    widget: const Icon(
                                      Icons.chrome_reader_mode_outlined,
                                      color: Colors.white,
                                    ),
                                    locked: controller
                                        .group
                                        .value!
                                        .userState[
                                            AuthenticationService.value.uid]!
                                        .ready,
                                    onTap: () {
                                      Get.toNamed('/read_chapter', parameters: {
                                        'storyId':
                                            controller.group.value!.story!.id,
                                        'chapterId': (controller.group.value!
                                                    .currentChapter -
                                                1)
                                            .toString(),
                                        'group': controller.group.value!.name,
                                      });
                                    },
                                  )
                                : Container(),
                          ),
                          const Gap(16),
                          GroupStatusBox(
                            group: controller.group.value!,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 500,
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
                    const Gap(40),
                  ],
                ),
              )
            : Column(
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
                              children: [
                                StoryBox(
                                  story: controller.group.value!.story,
                                ),
                                const Gap(12),
                                Obx(
                                  () => controller.group.value!.state ==
                                          GroupState.reading
                                      ? TeiaButton(
                                          text: controller
                                                  .group
                                                  .value!
                                                  .userState[
                                                      AuthenticationService
                                                          .value.uid]!
                                                  .ready
                                              ? 'You are done with this chapter'
                                              : 'Read chapter',
                                          color: color,
                                          widget: const Icon(
                                            Icons.chrome_reader_mode_outlined,
                                            color: Colors.white,
                                          ),
                                          locked: controller
                                              .group
                                              .value!
                                              .userState[AuthenticationService
                                                  .value.uid]!
                                              .ready,
                                          onTap: () {
                                            Get.toNamed('/read_chapter',
                                                parameters: {
                                                  'storyId': controller
                                                      .group.value!.story!.id,
                                                  'chapterId': (controller
                                                              .group
                                                              .value!
                                                              .currentChapter -
                                                          1)
                                                      .toString(),
                                                  'group': controller
                                                      .group.value!.name,
                                                });
                                          },
                                        )
                                      : Container(),
                                ),
                                const Gap(16),
                                GroupStatusBox(
                                  group: controller.group.value!,
                                  color: color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(40),
                ],
              ),
      ),
    );
  }
}
