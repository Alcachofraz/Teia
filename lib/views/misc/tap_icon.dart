import 'package:flutter/material.dart';

class TapIcon extends StatelessWidget {
  final Function()? onTap;
  final double splashRadius;
  final Widget icon;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? clickColor;
  final double? borderWidth;
  final BoxShape? shape;

  const TapIcon({
    Key? key,
    required this.icon,
    required this.onTap,
    this.splashRadius = 8.0,
    this.borderColor,
    this.backgroundColor = Colors.transparent,
    this.borderWidth,
    this.hoverColor,
    this.clickColor,
    this.shape = BoxShape.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
      child: Ink(
        decoration: BoxDecoration(
          border: borderWidth != null && borderColor != null ? Border.all(color: borderColor!, width: borderWidth!) : null,
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          hoverColor: hoverColor,
          splashColor: clickColor,
          borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(splashRadius),
            child: FittedBox(child: icon),
          ),
        ),
      ),
    );
  }
}
