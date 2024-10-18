import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/services/group_management_service.dart';

launchCreateAdventurePopup(BuildContext context) {
  TextEditingController adventureNameController = TextEditingController();
  TextEditingController adventurePasswordController = TextEditingController();
  GroupManagementService groupManagementService =
      Get.put(GroupManagementService());
  RxString error = ''.obs;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create adventure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter the name and password of the adventure you want to create:'),
            const SizedBox(height: 10),
            TextField(
              controller: adventureNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Adventure name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: adventurePasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Adventure password',
              ),
              obscureText: true,
            ),
            Obx(
              () => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  error.value,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.close(1),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              groupManagementService
                  .groupCreate(
                adventureNameController.text,
                adventurePasswordController.text,
              )
                  .then((bool result) {
                if (!result) {
                  error.value = "Can't create adventure. Choose another name.";
                } else {
                  Get.close(1);
                }
              });
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}
