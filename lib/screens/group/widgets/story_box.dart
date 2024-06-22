import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:teia/models/story.dart';
import 'package:teia/utils/utils.dart';

class StoryBox extends StatelessWidget {
  const StoryBox({
    super.key,
    required this.story,
  });

  final Story? story;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Story',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(4),
        if (story != null)
          Material(
            color: Utils.pageEditorSheetColor,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text(story!.name)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
