import 'package:teia/models/comment_message.dart';

class Comment {
  final List<CommentMessage> messages;
  final String id;
  final String storyId;
  final String chapterId;
  final String pageId;

  Comment({
    required this.messages,
    required this.id,
    required this.storyId,
    required this.chapterId,
    required this.pageId,
  });

  factory Comment.fromJson(Map<String, dynamic> json, String id) {
    return Comment(
      messages: (json['messages'] as List)
          .map((e) => CommentMessage.fromJson(e))
          .toList(),
      id: id,
      storyId: json['storyId'],
      chapterId: json['chapterId'],
      pageId: json['pageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((e) => e.toJson()).toList(),
      'storyId': storyId,
      'chapterId': chapterId,
      'pageId': pageId,
    };
  }
}
