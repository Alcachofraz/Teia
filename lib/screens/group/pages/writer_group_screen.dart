import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/views/teia_button.dart';

class WriterGroupScreen extends StatelessWidget {
  const WriterGroupScreen({super.key, required this.controller});

  final GroupController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TeiaButton(
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
      ),
    );
  }
}
