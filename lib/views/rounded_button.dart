import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Color color;
  final Widget? leading;
  final Widget? text;
  final Function()? onTap;
  final bool strokeOnly;
  final bool matchParent;
  final EdgeInsets padding;
  final List<Color>? gradient;
  const RoundedButton({
    Key? key,
    this.color = Colors.blue,
    this.leading,
    this.text,
    required this.onTap,
    this.strokeOnly = false,
    this.matchParent = true,
    this.padding = const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 16.0),
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1024.0),
        color: strokeOnly ? Colors.transparent : color,
        gradient: gradient != null
            ? LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.topLeft,
                colors: gradient!,
              )
            : null,
        border: strokeOnly ? Border.all(color: color, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1024.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(1024.0),
          splashColor: strokeOnly ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.5),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: matchParent ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (leading != null)
                  Padding(
                    padding: text != null ? const EdgeInsets.only(right: 12.0) : EdgeInsets.zero,
                    child: leading!,
                  ),
                if (text != null) text!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
