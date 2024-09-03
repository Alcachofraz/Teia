import 'package:flutter/material.dart';
import 'package:teia/views/misc/tile.dart';

class NewCommentCard extends StatelessWidget {
  NewCommentCard(
      {super.key, required this.onComplete, required this.onDismiss});

  final void Function(String) onComplete;
  final void Function() onDismiss;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Tile(
      width: double.infinity,
      padding: EdgeInsets.zero,
      radiusAll: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "New comment",
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDismiss,
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
            TextField(
              controller: controller,
              onSubmitted: (value) => onComplete(value),
              style: const TextStyle(fontSize: 11.0),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Your message',
                hintStyle: const TextStyle(
                  fontSize: 11.0,
                  color: Colors.grey,
                ),
                suffix: IconButton(
                  icon: const Icon(Icons.send, size: 16),
                  onPressed: () => onComplete(controller.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
