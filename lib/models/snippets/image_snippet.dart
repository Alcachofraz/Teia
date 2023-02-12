import 'package:teia/models/snippets/snippet.dart';

class ImageSnippet extends Snippet {
  String imageUrl;
  ImageSnippet(text, this.imageUrl) : super(text);
}
