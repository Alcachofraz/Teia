import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:teia/views/tap_icon.dart';

class GraphPageNode extends StatefulWidget {
  final int id;
  final Color? color;
  final Color? hoverColor;
  final Color? clickColor;
  final Function(int)? createPage;

  const GraphPageNode({
    Key? key,
    required this.id,
    this.color,
    this.hoverColor,
    this.clickColor,
    this.createPage,
  }) : super(key: key);

  @override
  State<GraphPageNode> createState() => _GraphPageNodeState();
}

class _GraphPageNodeState extends State<GraphPageNode> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: GraphPageNodePainter(color: widget.color),
          child: Material(
            color: Colors.transparent,
            shape: const GraphPageNodeBorder(),
            child: InkWell(
              hoverColor: widget.hoverColor,
              splashColor: widget.clickColor,
              customBorder: const GraphPageNodeBorder(),
              onTap: () {
                log('Clicked ${widget.id}');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                child: Text('Page ${widget.id}'),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: TapIcon(
            splashRadius: 0.0,
            icon: const Icon(
              Icons.add_rounded,
              size: 20.0,
            ),
            onTap: () {
              if (widget.createPage != null) {
                widget.createPage!(widget.id);
              }
            },
          ),
        ),
      ],
    );
  }
}

class GraphPageNodePainter extends CustomPainter {
  Color? color;

  GraphPageNodePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..strokeWidth = 0
      ..color = color ?? Colors.black;

    double w = size.width;
    double h = size.height;
    double plusDelta = h * 0.35;
    double cornerDelta = h * 0.08;

    var path = Path();
    path.moveTo(0, cornerDelta);
    path.quadraticBezierTo(0, 0, cornerDelta, 0);
    path.lineTo(w - cornerDelta, 0);
    path.quadraticBezierTo(w, 0, w, cornerDelta);
    path.lineTo(w, h - plusDelta - cornerDelta);
    path.quadraticBezierTo(w, h - plusDelta, w - cornerDelta, h - plusDelta);
    path.lineTo(w - plusDelta + cornerDelta, h - plusDelta);
    path.quadraticBezierTo(w - plusDelta, h - plusDelta, w - plusDelta, h - plusDelta + cornerDelta);
    path.lineTo(w - plusDelta, h - cornerDelta);
    path.quadraticBezierTo(w - plusDelta, h, w - plusDelta - cornerDelta, h);
    path.lineTo(cornerDelta, h);
    path.quadraticBezierTo(0, h, 0, h - cornerDelta);
    path.lineTo(0, cornerDelta);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GraphPageNodePainter oldDelegate) {
    return false;
  }
}

class GraphPageNodeBorder extends OutlinedBorder {
  const GraphPageNodeBorder({BorderSide side = BorderSide.none}) : super(side: side);

  Path customBorderPath(Rect rect) {
    double w = rect.width;
    double h = rect.height;
    double plusDelta = h * 0.33;
    double cornerDelta = h * 0.08;

    var path = Path();
    path.moveTo(0, cornerDelta);
    path.quadraticBezierTo(0, 0, cornerDelta, 0);
    path.lineTo(w - cornerDelta, 0);
    path.quadraticBezierTo(w, 0, w, cornerDelta);
    path.lineTo(w, h - plusDelta - cornerDelta);
    path.quadraticBezierTo(w, h - plusDelta, w - cornerDelta, h - plusDelta);
    path.lineTo(w - plusDelta + cornerDelta, h - plusDelta);
    path.quadraticBezierTo(w - plusDelta, h - plusDelta, w - plusDelta, h - plusDelta + cornerDelta);
    path.lineTo(w - plusDelta, h - cornerDelta);
    path.quadraticBezierTo(w - plusDelta, h, w - plusDelta - cornerDelta, h);
    path.lineTo(cornerDelta, h);
    path.quadraticBezierTo(0, h, 0, h - cornerDelta);
    path.lineTo(0, cornerDelta);
    return path;
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return GraphPageNodeBorder(side: side ?? this.side);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return customBorderPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return customBorderPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        canvas.drawPath(
          customBorderPath(rect),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.transparent
            ..strokeWidth = 0.0,
        );
    }
  }

  @override
  ShapeBorder scale(double t) => GraphPageNodeBorder(side: side.scale(t));
}
