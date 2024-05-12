import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';

class GroupScreen extends GetView<GroupController> {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GroupController());
    return ScreenWrapper(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
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
            ),
          ],
        ),
      ),
    );
  }
}
