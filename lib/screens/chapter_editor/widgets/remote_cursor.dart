import 'package:flutter/material.dart';

class RemoteCursor {
  String username;
  Color color;
  int index;

  RemoteCursor(this.username, this.color, this.index);

  factory RemoteCursor.fromMap(Map<String, dynamic>? map) {
    if (map == null) return RemoteCursor('', Colors.transparent, -1);
    return RemoteCursor(
      map['username'] as String,
      Color.fromARGB(255, map['color'][0], map['color'][1], map['color'][2]),
      map['index'] as int,
    );
  }

  factory RemoteCursor.fromString(String source) {
    var segments = source.split('@');
    return RemoteCursor(
        segments[0],
        Color.fromARGB(
            255, int.tryParse(segments[1]) ?? 255, int.tryParse(segments[2]) ?? 255, int.tryParse(segments[3]) ?? 255),
        int.tryParse(segments[4]) ?? -1);
  }

  @override
  String toString() {
    return '$username@${color.red}@${color.blue}@${color.green}@$index';
  }
}
