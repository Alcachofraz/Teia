import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/snippet.dart';

class ChoiceSnippet extends Snippet {
  int choice;
  ChoiceSnippet(
    LetterId from,
    LetterId to,
    this.choice,
  ) : super(from, to);

  @override
  Map<String, dynamic> toMap() => {
        'from': from.id,
        'to': to.id,
        'type': 1,
        'choice': choice,
      };

  @override
  Snippet deepCopy({String? text, LetterId? from, LetterId? to}) {
    return ChoiceSnippet(from ?? this.from, to ?? this.to, choice);
  }

  @override
  bool joinable(Snippet snippet) {
    return snippet is ChoiceSnippet && snippet.choice == choice;
  }

  @override
  bool operator ==(Object other) {
    return (other is ChoiceSnippet) && other.choice == choice && other.from == from && other.to == to;
  }

  @override
  int get hashCode => choice.hashCode + from.hashCode + to.hashCode + 1;

  @override
  String toString() {
    return '{from: $from, to: $to, id: $choice}';
  }
}
