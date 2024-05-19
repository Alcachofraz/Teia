import 'package:flutter/material.dart';

class StoryBox extends StatelessWidget {
  const StoryBox({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
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
        width: 300,
        height: double.infinity,
      ),
    );
  }
}
