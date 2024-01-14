import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/page.dart';
/*
class SnippetFactory {
  static List<Letter> letterSublist(List<Letter> list, LetterId start,
      LetterId end, bool startInclusive, bool endInclusive) {
    int startIndex = list.indexWhere((letter) => letter.id == start);
    int endIndex = list.indexWhere((letter) => letter.id == end);
    return list.sublist(
      startIndex + (startInclusive ? 0 : 1),
      endIndex + (endInclusive ? 1 : 0),
    );
  }

  static String stringFromRange(
    List<Letter> list,
    LetterId start,
    LetterId end,
    bool startInclusive,
    bool endInclusive,
  ) {
    return letterSublist(
      list,
      start,
      end,
      startInclusive,
      endInclusive,
    ).fold(
      '',
      (previous, element) => previous + element.letter,
    );
  }

  static List<TextSpan> spansFromPage(
      tPage page, Function(String url) onImage, Function(int id) onChoice) {
    List<TextSpan> spans = [];
    page.snippets.sort((a, b) => a.from.compareTo(b.from));
    spans.add(
      TextSpan(
        text: stringFromRange(
          page.letters,
          page.letters.first.id,
          page.snippets.first.from,
          true,
          false,
        ),
      ),
    );
    for (int i = 0; i < page.snippets.length; i++) {
      Function()? onTap;
      if (page.snippets[i] is ImageSnippet) {
        onTap = () => onImage((page.snippets[i] as ImageSnippet).url);
      } else if (page.snippets[i] is ChoiceSnippet) {
        onTap = () => onChoice((page.snippets[i] as ChoiceSnippet).choice);
      }
      spans.add(
        TextSpan(
          text: stringFromRange(
            page.letters,
            page.snippets[i].from,
            page.snippets[i].to,
            true,
            true,
          ),
          recognizer: TapGestureRecognizer()..onTap = onTap,
        ),
      );
      spans.add(
        TextSpan(
          text: stringFromRange(
            page.letters,
            page.snippets[i].to,
            i + 1 >= page.snippets.length
                ? page.letters.last.id
                : page.snippets[i + 1].from,
            false,
            false,
          ),
        ),
      );
    }
    return spans;
  }
}
*/
