abstract class Snippet {
  String text;
  Snippet(this.text);
  Snippet deepCopy({String? text});
  bool joinable(Snippet snippet);

  toMap();
}
