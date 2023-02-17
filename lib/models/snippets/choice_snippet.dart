import 'package:teia/models/snippets/snippet.dart';

class ChoiceSnippet extends Snippet {
  int pageId;
  ChoiceSnippet(String text, this.pageId) : super(text);
}
