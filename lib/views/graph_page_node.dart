import 'dart:developer';

import 'package:flutter/material.dart';

class GraphPageNode extends StatefulWidget {
  final int id;
  const GraphPageNode({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<GraphPageNode> createState() => _GraphPageNodeState();
}

class _GraphPageNodeState extends State<GraphPageNode> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            log('Clicked ${widget.id}');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.green[200]!, spreadRadius: 1),
              ],
            ),
            child: Text('Page ${widget.id}'),
          ),
        ),
      ],
    );
  }
}
