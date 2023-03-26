import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/snippet.dart';

class ChoiceSnippet extends Snippet {
  int id;
  ChoiceSnippet(
    LetterId from,
    LetterId to,
    this.id,
  ) : super(from, to);

  @override
  Map<String, dynamic> toMap() => {
        'from': from.id,
        'to': to.id,
        'type': 1,
        'choice': id,
      };

  @override
  Snippet deepCopy({String? text, LetterId? from, LetterId? to}) {
    return ChoiceSnippet(from ?? this.from, to ?? this.to, id);
  }

  @override
  bool joinable(Snippet snippet) {
    return snippet is ChoiceSnippet && snippet.id == id;
  }

  @override
  bool operator ==(Object other) {
    return (other is ChoiceSnippet) && other.id == id && other.from == from && other.to == to;
  }

  @override
  int get hashCode => id.hashCode + from.hashCode + to.hashCode + 1;

  @override
  String toString() {
    return '{from: $from, to: $to, id: $id}';
  }
}
