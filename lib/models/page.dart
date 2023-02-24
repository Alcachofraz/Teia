import 'package:teia/models/snippets/snippet.dart';

class Page {
  final int id;

  final List<Snippet> snippets;

  Page(this.id, this.snippets);

  String getRawText() {
    String ret = '';
    for (Snippet snippet in snippets) {
      ret += snippet.text;
    }
    return ret;
  }

  @override
  String toString() {
    return 'Page{id: $id}';
  }
}
