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

  @override
  bool joinable(Snippet snippet) {
    return snippet is TextSnippet;
  }

  @override
  bool operator ==(Object other) {
    return (other is Snippet) && other.text == text;
  }

  @override
  int get hashCode => text.hashCode + 0;
}
