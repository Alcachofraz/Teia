import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:teia/models/story.dart';
import 'package:teia/views/teia_button.dart';

class StoryBox extends StatelessWidget {
  const StoryBox({
    super.key,
    required this.color,
    required this.story,
  });

  final Color color;
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
        Material(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: color,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text(
                  "Do you want to read an already existing full story? (everyone will be a reader)",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                const Gap(4),
                TeiaButton(
                  widget: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  text: "Search",
                ),
                const Gap(8),
                const Text(
                  "Or do you want to create a new story? (at least one of you will be a writer)",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                const Gap(4),
                TeiaButton(
                  widget: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  text: "Create",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
