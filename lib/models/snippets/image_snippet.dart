import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/snippet.dart';

class ImageSnippet extends Snippet {
  String url;
  ImageSnippet(
    LetterId from,
    LetterId to,
    this.url,
  ) : super(from, to);

  @override
  Map<String, dynamic> toMap() => {
        'from': from.id,
        'to': to.id,
        'type': 2,
        'url': url,
      };

  @override
  Snippet deepCopy({String? text, LetterId? from, LetterId? to}) {
    return ImageSnippet(from ?? this.from, to ?? this.to, url);
  }

  @override
  bool joinable(Snippet snippet) {
    return snippet is ImageSnippet && snippet.url == url;
  }

  @override
  bool operator ==(Object other) {
    return (other is ImageSnippet) && other.url == url && other.from == from && other.to == to;
  }

  @override
  int get hashCode => url.hashCode + from.hashCode + to.hashCode + 2;

  @override
  String toString() {
    return '{from: $from, to: $to, url: $url}';
  }
}
