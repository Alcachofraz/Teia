import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:teia/views/misc/tile.dart';

class ExpandableTile extends StatefulWidget {
  final Widget expanded;
  final Widget collapsed;
  final Duration? duration;
  final BorderRadius? borderRadius;
  final void Function(bool)? onExpansionChanged;

  const ExpandableTile({
    super.key,
    required this.collapsed,
    required this.expanded,
    this.onExpansionChanged,
    this.duration,
    this.borderRadius,
  });

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return Tile(
      padding: EdgeInsets.zero,
      border: widget.borderRadius != null
          ? RoundedRectangleBorder(
              borderRadius: widget.borderRadius!,
            )
          : null,
      onTap: () {
        setState(() {
          expanded = !expanded;
          log(expanded.toString());
          if (widget.onExpansionChanged != null) {
            widget.onExpansionChanged!(expanded);
          }
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedSize(
              duration: widget.duration ?? const Duration(milliseconds: 300),
              child: expanded ? widget.expanded : widget.collapsed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 28.0, 8.0, 28.0),
            child: AnimatedRotation(
              turns: expanded ? 0.25 : 0.75,
              duration: widget.duration ?? const Duration(milliseconds: 300),
              child: const Icon(Icons.chevron_left),
            ),
          )
        ],
      ),
    );
  }
}
