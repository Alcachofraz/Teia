import 'package:flutter/material.dart';
import 'package:teia/views/text_editor/text_part_style_definition.dart';

class PageEditingController extends TextEditingController {
  final TextPartStyleDefinitions styles;
  final Pattern combinedPattern;

  PageEditingController({
    required this.styles,
  }) : combinedPattern = styles.createCombinedPatternBasedOnStyleMap();

  List<Color> highlightColors = [
    Colors.red[200]!,
    Colors.blue[200]!,
    Colors.green[200]!,
  ];

  //List<Snippet> snippets;

  /*void update(List<Snippet> snippets) {
    // String with full text
    String text = '';
    // Update snippets
    this.snippets = snippets;
    for (var snippet in snippets) {
      text += snippet.text;
    }
    // Iterate snipepts to generate new spans
    value = value.copyWith(
      text: text,
    );
  }*/

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    return TextSpan(style: style, children: [
      TextSpan(text: text.substring(0, text.length > 2 ? 2 : text.length)),
      if (text.length > 2) TextSpan(text: text.substring(2, text.length), style: const TextStyle(color: Colors.red)),
    ]);
  }

  /*@override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    // Iterator index for colors
    int color = 0;
    // TextSpans
    List<TextSpan> spans = [];
    for (Snippet snippet in snippets) {
      // Add raw text to 'text'
      text += snippet.text;
      log(text);
      if (snippet is TextSnippet) {
        spans.add(
          TextSpan(text: snippet.text),
        );
      } else if (snippet is ChoiceSnippet) {
        spans.add(
          TextSpan(
            style: TextStyle(backgroundColor: highlightColors[color]),
            children: [
              TextSpan(text: snippet.text),
              const WidgetSpan(
                child: Icon(Icons.link),
              ),
            ],
          ),
        );
      } else if (snippet is ImageSnippet) {
        spans.add(
          TextSpan(
            style: TextStyle(backgroundColor: highlightColors[color]),
            children: [
              TextSpan(text: snippet.text),
              const WidgetSpan(
                child: Icon(Icons.image),
              ),
            ],
          ),
        );
      }
      if (++color > 2) color = 0;
    }
    return TextSpan(
      style: style,
      children: spans,
    );
  }*/
}
