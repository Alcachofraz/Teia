import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StoryBox extends StatelessWidget {
  const StoryBox({
    super.key,
    required this.color,
  });

  final Color color;

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
          child: const SizedBox(
            width: double.infinity,
            height: 100,
          ),
        ),
      ],
    );
  }
}
