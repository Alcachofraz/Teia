import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/image_snippet.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/models/editing_page.dart';
import 'package:teia/views/text_editor/widgets/expandable_tile.dart';

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
  bool expanded = false;

  Widget _getHeader(Snippet snipept, String text) {
    if (widget.snippet is ImageSnippet) {
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              (widget.snippet as ImageSnippet).url,
              height: 64,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text),
            ),
          ),
        ],
      );
    } else if (widget.snippet is ImageSnippet) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              (widget.snippet as ChoiceSnippet).id.toString(),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(text),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _getContent(Snippet snipept, String text) {
    if (widget.snippet is ImageSnippet) {
      return Row(mainAxisSize: MainAxisSize.max, children: [
        Column(
          children: [
            Text(text),
            Image.network(
              (widget.snippet as ImageSnippet).url,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ]);
    } else if (widget.snippet is ChoiceSnippet) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              (widget.snippet as ChoiceSnippet).id.toString(),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(text),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

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
    return ExpandableTile(
      expanded: _getContent(widget.snippet, text),
      collapsed: _getHeader(widget.snippet, text),
      borderRadius: BorderRadius.circular(8.0),
    );
  }
}
