import 'package:teia/models/snippets/snippet.dart';

class ChoiceSnippet extends Snippet {
  int id;
  ChoiceSnippet(String text, this.id) : super(text);

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        'type': 1,
        'choice': id,
      };

  @override
  Snippet deepCopy({String? text}) {
    return ChoiceSnippet(text ?? this.text, id);
  }

  @override
  bool joinable(Snippet snippet) {
    return snippet is ChoiceSnippet && snippet.id == id;
  }

  @override
  bool operator ==(Object other) {
    return (other is ChoiceSnippet) && other.text == text && other.id == id;
  }

  @override
  int get hashCode => text.hashCode + id.hashCode + 1;
}
