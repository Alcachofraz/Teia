import 'package:flutter/material.dart';
import 'package:teia/models/comment.dart';
import 'package:teia/screens/chapter_editor/widgets/comments/comment_message_widget.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:gap/gap.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.onRespond,
  });

  final Comment comment;
  final Future<void> Function(Comment, String) onRespond;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool showingMiddleComments = false;
  final TextEditingController controller = TextEditingController();

  Future<void> sendMessage(String message) async {
    await widget.onRespond(widget.comment, message);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Tile(
      width: double.infinity,
      padding: EdgeInsets.zero,
      radiusAll: 4.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await ChapterManagementService.value
                        .removeComment(widget.comment);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Gap(4),
                        Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 20,
                        ),
                        Gap(4),
                        Text(
                          'Resolve',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            CommentMessageWidget(commentMessage: widget.comment.messages.first),
            if (widget.comment.messages.length > 2)
              if (showingMiddleComments)
                for (int i = 1; i < widget.comment.messages.length - 1; i++)
                  CommentMessageWidget(
                      commentMessage: widget.comment.messages[i])
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: InkWell(
                    onTap: () => setState(() => showingMiddleComments = true),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(),
                        ),
                        Text(
                          "  show more  ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),
                ),
            if (widget.comment.messages.length > 1)
              CommentMessageWidget(
                  commentMessage: widget.comment.messages.last),
            TextField(
              controller: controller,
              onSubmitted: (value) async => await sendMessage(value),
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
                  onPressed: () async => await sendMessage(controller.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
