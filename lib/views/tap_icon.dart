import 'package:flutter/material.dart';

class TapIcon extends StatelessWidget {
  final Function()? onTap;
  final double splashRadius;
  final Icon icon;
  const TapIcon({Key? key, required this.icon, required this.onTap, this.splashRadius = 8.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: Colors.grey.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.all(splashRadius),
          child: icon,
        ),
      ),
    );
  }
}
