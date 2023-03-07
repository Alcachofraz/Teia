import 'package:teia/models/snippets/snippet.dart';

class TextSnippet extends Snippet {
  TextSnippet(String text) : super(text);

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        'type': 0,
      };

  @override
  Snippet deepCopy({String? text}) {
    return TextSnippet(text ?? this.text);
  }
}
