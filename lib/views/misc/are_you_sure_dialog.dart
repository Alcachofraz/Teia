import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> launchAreYouSurePopup(
  BuildContext context, {
  dynamic Function()? onReady,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Ready up'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.close(1),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onReady,
            child: const Text('I\'m ready!'),
          ),
        ],
      );
    },
  );
}
