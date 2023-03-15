import 'package:teia/models/snippets/snippet.dart';

class ImageSnippet extends Snippet {
  String url;
  ImageSnippet(String text, this.url) : super(text);

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        'type': 2,
        'url': url,
      };

  @override
  Snippet deepCopy({String? text}) {
    return ImageSnippet(text ?? this.text, url);
  }

  @override
  bool joinable(Snippet snippet) {
    return snippet is ImageSnippet && snippet.url == url;
  }

  @override
  bool operator ==(Object other) {
    return (other is ImageSnippet) && other.text == text && other.url == url;
  }

  @override
  int get hashCode => text.hashCode + url.hashCode + 2;
}
