import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/views/teia_button.dart';

openDeletePopupError(BuildContext context, int pageId) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Can\'t delete Page $pageId',
          style: const TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "The page you're trying to delete is either:\n  • The root of the chapter;\n  • Linked to its parents through snippets;\n  • Connected to children.",
            ),
            const SizedBox(height: 10),
            TeiaButton(
              onTap: () => Get.close(1),
              text: 'Close',
            ),
          ],
        ),
      );
    },
  );
}
