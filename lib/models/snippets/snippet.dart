import 'package:teia/models/letter.dart';

abstract class Snippet {
  LetterId from;
  LetterId to;
  Snippet(
    this.from,
    this.to,
  );
  Snippet deepCopy({LetterId? from, LetterId? to});
  bool joinable(Snippet snippet);
  Map<String, dynamic> toMap();
}
