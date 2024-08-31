import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/services/group_management_service.dart';

launchCreateAdventurePopup(BuildContext context) {
  TextEditingController adventureNameController = TextEditingController();
  TextEditingController adventurePasswordController = TextEditingController();
  GroupManagementService groupManagementService =
      Get.put(GroupManagementService());
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Join adventure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter the name and password of the adventure you want to join:'),
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
                  .then(
                    (_) => Get.close(1),
                  );
            },
            child: const Text('Join'),
          ),
        ],
      );
    },
  );
}
