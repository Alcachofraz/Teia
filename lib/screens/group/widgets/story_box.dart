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
<<<<<<< Updated upstream
            ),
          ),
          child: const SizedBox(
            width: double.infinity,
            height: 100,
=======
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TeiaButton(
                  widget: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  text: "Search",
                ),
                const Gap(8),
                TeiaButton(
                  widget: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  text: "Create",
                ),
              ],
            ),
>>>>>>> Stashed changes
          ),
        ),
      ],
    );
  }
}
