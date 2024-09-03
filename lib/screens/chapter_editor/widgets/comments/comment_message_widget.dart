import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:teia/models/comment_message.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';

class CommentMessageWidget extends StatelessWidget {
  const CommentMessageWidget({super.key, required this.commentMessage});

  final CommentMessage commentMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: AuthenticationService.value.uid == commentMessage.uid
          ? MyMessage(
              commentMessage: commentMessage,
            )
          : OtherMessage(
              commentMessage: commentMessage,
            ),
    );
  }
}

class OtherMessage extends StatelessWidget {
  const OtherMessage({super.key, required this.commentMessage});

  final CommentMessage commentMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16.0,
          backgroundImage: AssetImage(
            ArtService.value.assetPath(commentMessage.avatar),
          ),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commentMessage.username,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                commentMessage.message,
                style: const TextStyle(
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class MyMessage extends StatelessWidget {
  const MyMessage({super.key, required this.commentMessage});

  final CommentMessage commentMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commentMessage.username,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                commentMessage.message,
                style: const TextStyle(
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        CircleAvatar(
          radius: 16.0,
          backgroundImage: AssetImage(
            ArtService.value.assetPath(commentMessage.avatar),
          ),
        ),
      ],
    );
  }
}
