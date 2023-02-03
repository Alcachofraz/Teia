import 'package:flutter/material.dart';

class Tile extends StatefulWidget {
  final EdgeInsets? padding;
  final Color? color;
  final double radiusTopLeft;
  final double radiusTopRight;
  final double radiusBottomLeft;
  final double radiusBottomRight;
  final double radiusAll;
  final double spread;
  final double blur;
  final double? height;
  final double? width;
  final Widget? child;
  final GestureTapCallback? onTap;

  const Tile({
    Key? key,
    this.padding,
    this.color = Colors.white,
    this.radiusTopLeft = 0.0,
    this.radiusTopRight = 0.0,
    this.radiusBottomLeft = 0.0,
    this.radiusBottomRight = 0.0,
    this.radiusAll = 0.0,
    this.spread = 0.0,
    this.blur = 4.0,
    this.height,
    this.width,
    this.child,
    this.onTap,
  }) : super(key: key);

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.circular(widget.radiusAll == 0 ? widget.radiusTopLeft : widget.radiusAll),
      topRight: Radius.circular(widget.radiusAll == 0 ? widget.radiusTopRight : widget.radiusAll),
      bottomLeft: Radius.circular(widget.radiusAll == 0 ? widget.radiusBottomLeft : widget.radiusAll),
      bottomRight: Radius.circular(widget.radiusAll == 0 ? widget.radiusBottomRight : widget.radiusAll),
    );
    return Card(
      margin: widget.padding,
      color: widget.color,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}
