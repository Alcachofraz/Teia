import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:teia/models/editing_page.dart';

class SnippetInfoCard extends StatefulWidget {
  final Snippet snippet;
  final EditingPage page;
  const SnippetInfoCard({
    Key? key,
    required this.snippet,
    required this.page,
  }) : super(key: key);

  @override
  State<SnippetInfoCard> createState() => _SnippetInfoCardState();
}

class _SnippetInfoCardState extends State<SnippetInfoCard> {
  @override
  Widget build(BuildContext context) {
    String text = '';
    // Get text of Snippet
    for (var letter in widget.page.letters) {
      if (letter.id.compareTo(widget.snippet.from) >= 0) {
        text += letter.letter;
      }
      if (letter.id.compareTo(widget.snippet.to) >= 0) {
        break;
      }
    }
    return Tile(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Text(text),
        ],
      ),
    );
  }
}
