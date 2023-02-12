import 'package:teia/models/snippets/snippet.dart';

class SecretSnippet extends Snippet {
  String secret;
  SecretSnippet(text, this.secret) : super(text);
}
