import 'package:teia/models/snippets/snippet.dart';

class ImageSnippet extends Snippet {
  String imageUrl;
  ImageSnippet(String text, this.imageUrl) : super(text);
}
