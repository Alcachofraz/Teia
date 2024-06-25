import 'package:flutter/material.dart';

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
            onPressed: () {
              Navigator.pop(context);
            },
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
