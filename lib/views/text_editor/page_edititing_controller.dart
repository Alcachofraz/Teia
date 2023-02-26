import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:teia/models/snippets/snippet.dart';

class PageEditingController extends TextEditingController {
  int colorIterator = 0;

  PageEditingController(/*{
    required this.snippets,
  }*/
      );

  int snippetIcons = 0;

  List<Color> highlightColors = [
    Colors.red[200]!,
    Colors.blue[200]!,
    Colors.green[200]!,
  ];

  @override
  set value(TextEditingValue newValue) {
    assert(
      !newValue.composing.isValid || newValue.isComposingRangeValid,
      'New TextEditingValue $newValue has an invalid non-empty composing range '
      '${newValue.composing}. It is recommended to use a valid composing range, '
      'even for readonly text fields',
    );

    super.value = newValue.copyWith(
        selection: TextSelection(
      baseOffset: newValue.selection.baseOffset + snippetIcons,
      extentOffset: newValue.selection.extentOffset + snippetIcons,
    ));
  }

  Color get highlightColor {
    Color ret = highlightColors[colorIterator];
    if (++colorIterator >= highlightColors.length) colorIterator = 0;
    return ret;
  }

  List<Snippet> snippets = [];

  @override
  set text(String newText) {
    log(newText);
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  set textSnippets(List<Snippet> snippets) {
    // String with full text
    String fullText = '';
    // Update snippets
    this.snippets = snippets;
    for (var snippet in snippets) {
      fullText += snippet.text;
    }
    value = value.copyWith(
      text: fullText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    /*List<TextSpan> spans = [];
    for (Snippet snippet in snippets) {
      spans.add(TextSpan(text: snippet.text, style: snippet is TextSnippet ? TextStyle(color: highlightColor) : const TextStyle()));
    }
    return TextSpan(style: style, children: spans);*/
    List<TextSpan> spans = [];
    snippetIcons = 0;
    text.splitMapJoin(
      RegExp(
        '[.,?!]|(?:(the|a|an) +)',
        multiLine: true,
        caseSensitive: false,
      ),
      onMatch: (Match match) {
        final String textPart = match.group(0) ?? '';

        snippetIcons++;

        spans.add(
          TextSpan(style: const TextStyle(color: Colors.blue), children: [
            TextSpan(
              text: textPart,
            ),
            const WidgetSpan(child: Icon(Icons.image)),
          ]),
        );

        return '';
      },
      onNonMatch: (String text) {
        spans.add(
          TextSpan(
            text: text,
          ),
        );

        return '';
      },
    );

    return TextSpan(style: style, children: spans);
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
