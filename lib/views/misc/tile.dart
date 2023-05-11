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
  final BorderSide borderSide;
  final Color? clickColor;
  final Color? hoverColor;
  final GestureTapCallback? onTap;
  final double? elevation;
  final ShapeBorder? border;

  const Tile({
    Key? key,
    this.padding,
    this.elevation,
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
    this.borderSide = BorderSide.none,
    this.clickColor,
    this.hoverColor,
    this.onTap,
    this.border,
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
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Card(
        margin: widget.padding,
        color: widget.color,
        elevation: widget.elevation,
        shape: widget.border ??
            RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: widget.borderSide,
            ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            hoverColor: widget.hoverColor,
            splashColor: widget.clickColor,
            customBorder: widget.border ??
                RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
