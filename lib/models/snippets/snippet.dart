abstract class Snippet {
  String text;
  Snippet(this.text);
  Snippet deepCopy({String? text});

  toMap();
}
