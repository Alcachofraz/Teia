import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:teia/models/story.dart';
import 'package:teia/views/teia_button.dart';

class StoryBox extends StatelessWidget {
  const StoryBox({
    super.key,
    required this.color,
    required this.story,
    this.onCreate,
  });

  final Color color;
  final Story? story;
  final Function()? onCreate;

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
              child: Row(
                children: [
                  Expanded(child: Text(story!.name)),
                ],
              ),
            ),
          ),
        if (story != null) const Gap(12),
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
                    fontSize: 13,
                  ),
                ),
                const Gap(6),
                TeiaButton(
                  widget: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  text: "Search",
                ),
                const Gap(4),
                Divider(
                  color: Colors.grey[200],
                  thickness: 1.5,
                ),
                const Gap(4),
                const Text(
                  "Or do you want to create a new story? (at least one of you will be a writer)",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                const Gap(6),
                TeiaButton(
                  onTap: onCreate,
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
