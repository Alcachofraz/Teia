import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/snippet.dart';

class TextSnippet extends Snippet {
  TextSnippet(
    LetterId from,
    LetterId to,
  ) : super(from, to);

  @override
  Map<String, dynamic> toMap() => {
        'from': from.id,
        'to': to.id,
        'type': 0,
      };

  @override
  Snippet deepCopy({String? text, LetterId? from, LetterId? to}) {
    return TextSnippet(from ?? this.from, to ?? this.to);
  }

  @override
  bool joinable(Snippet snippet) {
    return snippet is TextSnippet;
  }

  @override
  bool operator ==(Object other) {
    return (other is Snippet) && other.from == from && other.to == to;
  }

  @override
  int get hashCode => from.hashCode + to.hashCode + 0;

  @override
  String toString() {
    return '{from: $from, to: $to}';
  }
}
