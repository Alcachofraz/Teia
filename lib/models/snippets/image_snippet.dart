import 'package:teia/models/snippets/snippet.dart';

class ImageSnippet extends Snippet {
  String imageUrl;
  ImageSnippet(String text, this.imageUrl) : super(text);

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        'type': 2,
        'url': imageUrl,
      };

  @override
  Snippet deepCopy({String? text}) {
    return ImageSnippet(text ?? this.text, imageUrl);
  }
}
