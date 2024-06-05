import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/services/group_management_service.dart';
import 'package:teia/services/story_management_service.dart';

Future<void> launchCreateStoryPopup(BuildContext context, String groupName) {
  TextEditingController storyNameController = TextEditingController();
  GroupManagementService groupManagementService =
      Get.put(GroupManagementService());
  StoryManagementService storyManagementService =
      Get.put(StoryManagementService());
  RxBool loading = false.obs;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create story'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter the name of your story:',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: storyNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Story name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          Obx(
            () => TextButton(
              onPressed: loading.value
                  ? null
                  : () async {
                      loading.value = true;
                      String? id = await storyManagementService
                          .storyCreate(storyNameController.text);
                      if (id != null) {
                        await groupManagementService.groupSetStory(
                          groupName,
                          id,
                        );
                        Get.back();
                      } else {
                        Get.snackbar(
                          'Error',
                          'Could not create story',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                      loading.value = false;
                    },
              child: const Text('Create'),
            ),
          ),
        ],
      );
    },
  );
}
