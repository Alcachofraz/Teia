import 'package:flutter/material.dart';
import 'package:teia/views/tap_icon.dart';
import 'package:teia/views/tile.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class GraphPageNode extends StatefulWidget {
  final int id;
  final Color? insideColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? clickColor;
  final Color? iconColor;
  final Function(int)? createPage;
  final Function(int)? dissociatePage;
  final Function(int)? connectPage;
  final Function(int)? enterPage;
  final bool simplified;

  const GraphPageNode({
    Key? key,
    required this.id,
    this.insideColor,
    this.borderColor,
    this.hoverColor,
    this.iconColor,
    this.clickColor,
    this.createPage,
    this.dissociatePage,
    this.connectPage,
    this.enterPage,
    this.simplified = false,
  }) : super(key: key);

  @override
  State<GraphPageNode> createState() => _GraphPageNodeState();
}

class _GraphPageNodeState extends State<GraphPageNode> {
  @override
  Widget build(BuildContext context) {
    return widget.simplified
        ? Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Tile(
              clickColor: widget.clickColor,
              hoverColor: widget.hoverColor,
              radiusAll: 8.0,
              padding: EdgeInsets.zero,
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.black,
                width: 1.5,
              ),
              onTap: () {
                if (widget.enterPage != null) {
                  widget.enterPage!(widget.id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28.0),
                child: Text('Page ${widget.id}'),
              ),
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Tile(
                  clickColor: widget.clickColor,
                  hoverColor: widget.hoverColor,
                  radiusAll: 8.0,
                  padding: EdgeInsets.zero,
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Colors.black,
                    width: 1.5,
                  ),
                  onTap: () {
                    if (widget.enterPage != null) {
                      widget.enterPage!(widget.id);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28.0),
                    child: Text('Page ${widget.id}'),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Tooltip(
                    message: 'Dissociate from parent',
                    child: TapIcon(
                      splashRadius: 4.0,
                      borderColor: widget.borderColor ?? Colors.black,
                      borderWidth: 1.5,
                      backgroundColor: widget.insideColor,
                      clickColor: widget.clickColor,
                      hoverColor: widget.hoverColor,
                      icon: Icon(
                        MdiIcons.contentCut,
                        size: 14.0,
                        color: widget.iconColor,
                      ),
                      onTap: () {
                        if (widget.dissociatePage != null) {
                          widget.dissociatePage!(widget.id);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Tooltip(
                      message: 'Create new child',
                      child: TapIcon(
                        splashRadius: 4.0,
                        borderColor: widget.borderColor ?? Colors.black,
                        borderWidth: 1.5,
                        backgroundColor: widget.insideColor,
                        clickColor: widget.clickColor,
                        hoverColor: widget.hoverColor,
                        icon: Icon(
                          MdiIcons.fileDocumentPlusOutline,
                          size: 14.0,
                          color: widget.iconColor,
                        ),
                        onTap: () {
                          if (widget.createPage != null) {
                            widget.createPage!(widget.id);
                          }
                        },
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Connect to child',
                    child: TapIcon(
                      splashRadius: 4.0,
                      borderColor: widget.borderColor ?? Colors.black,
                      borderWidth: 1.5,
                      backgroundColor: widget.insideColor,
                      clickColor: widget.clickColor,
                      hoverColor: widget.hoverColor,
                      icon: Icon(
                        MdiIcons.transitConnectionVariant,
                        size: 14.0,
                        color: widget.iconColor,
                      ),
                      onTap: () {
                        if (widget.connectPage != null) {
                          widget.connectPage!(widget.id);
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          );

    /*Stack(
      children: [
        CustomPaint(
          painter: GraphPageNodePainter(
            color: widget.insideColor ?? Colors.black,
            borderColor: widget.borderColor ?? Colors.black,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const GraphPageNodeBorder(),
            child: InkWell(
              hoverColor: widget.hoverColor,
              splashColor: widget.clickColor,
              customBorder: const GraphPageNodeBorder(),
              onTap: () {
                if (widget.enterPage != null) {
                  widget.enterPage!(widget.id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28.0),
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
            icon: Icon(
              Icons.add_rounded,
              size: 20.0,
              color: widget.plusColor,
            ),
            onTap: () {
              if (widget.createPage != null) {
                widget.createPage!(widget.id);
              }
            },
          ),
        ),
      ],
    );*/
  }
}
/*
class GraphPageNodePainter extends CustomPainter {
  Color color;
  Color borderColor;

  GraphPageNodePainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(GraphPageNodePainter oldDelegate) {
    return false;
  }
}

class GraphPageNodeBorder extends OutlinedBorder {
  const GraphPageNodeBorder({
    BorderSide side = BorderSide.none,
  }) : super(side: side);

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
            ..strokeWidth = 0.0,
        );
    }
  }

  @override
  ShapeBorder scale(double t) => GraphPageNodeBorder(side: side.scale(t));
}
*/