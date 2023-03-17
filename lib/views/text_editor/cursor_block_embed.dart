import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

class CursorBlockEmbed extends CustomBlockEmbed {
  const CursorBlockEmbed(String value) : super(cursorType, value);

  static const String cursorType = 'cursor';

  static CursorBlockEmbed fromDocument(String cursor) => CursorBlockEmbed(cursor);

  Document get document => Document.fromJson(jsonDecode(data));
}
