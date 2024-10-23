import 'package:flutter/material.dart';

class Expandable extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final bool expanded;
  final Function()? onTap;

  const Expandable({
    super.key,
    required this.title,
    required this.children,
    this.expanded = false,
    this.onTap,
  });

  @override
  _ExpandableState createState() => _ExpandableState();
}

class _ExpandableState extends State<Expandable>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.white,
                child: InkWell(
                  onTap: widget.onTap,
                  child: widget.title,
                ),
              ),
              ...widget.children,
            ],
          ),
        ),
      ],
    );
  }
}
