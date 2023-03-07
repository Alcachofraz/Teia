import 'package:teia/models/snippets/snippet.dart';

class ChoiceSnippet extends Snippet {
  int pageId;
  ChoiceSnippet(String text, this.pageId) : super(text);

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        'type': 1,
        'choice': pageId,
      };

  @override
  Snippet deepCopy({String? text}) {
    return ChoiceSnippet(text ?? this.text, pageId);
  }
}
