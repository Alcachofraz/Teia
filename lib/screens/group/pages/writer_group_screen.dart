import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/screens/group/widgets/story_box.dart';
import 'package:teia/screens/group/widgets/users_box.dart';
import 'package:teia/views/teia_button.dart';

class WriterGroupScreen extends StatelessWidget {
  const WriterGroupScreen({super.key, required this.controller});

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
                          TeiaButton(
                            text: 'Chapter Editor',
                            widget: const Icon(
                              Icons.schema_outlined,
                              color: Colors.white,
                            ),
                            onTap: () {
                              Get.toNamed('/chapter_editor', parameters: {
                                'storyId': controller.group.value!.story!.id,
                                'chapterId': '1',
                              });
                            },
                          )
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
