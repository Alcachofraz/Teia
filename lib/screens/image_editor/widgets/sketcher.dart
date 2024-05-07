import 'package:flutter/material.dart';
import 'package:teia/screens/image_editor/widgets/drawn_line.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine?> lines;

  Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i]!.path.length - 1; ++j) {
        paint.color = lines[i]!.color;
        paint.strokeWidth = lines[i]!.width;
        canvas.drawLine(lines[i]!.path[j], lines[i]!.path[j + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
