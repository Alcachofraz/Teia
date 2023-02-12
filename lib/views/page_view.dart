import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/page.dart';
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/raw_snippet.dart';
import 'package:teia/models/snippets/secret_snippet.dart';
import 'package:teia/models/snippets/snippet.dart';

class PageView extends StatefulWidget {
  final Page page;
  final Function()? onChoice;
  final Function()? onImage;
  final Function()? onSecret;
  const PageView({
    super.key,
    required this.page,
    required this.onChoice,
    required this.onImage,
    required this.onSecret,
  });

  @override
  State<PageView> createState() => _PageViewState();
}

class _PageViewState extends State<PageView> {
  List<TextSpan> snippets = [];

  @override
  void initState() {
    for (Snippet snippet in widget.page.snippets) {
      if (snippet is RawSnippet) {
        snippets.add(TextSpan(text: snippet.text));
      } else if (snippet is ChoiceSnippet) {
        snippets.add(TextSpan(
          text: snippet.text,
          recognizer: TapGestureRecognizer()..onTap = widget.onChoice,
        ));
      } else if (snippet is RawSnippet) {
        snippets.add(TextSpan(
          text: snippet.text,
          recognizer: TapGestureRecognizer()..onTap = widget.onImage,
        ));
      } else if (snippet is SecretSnippet) {
        snippets.add(TextSpan(
          text: snippet.text,
          recognizer: TapGestureRecognizer()..onTap = widget.onSecret,
        ));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: snippets,
      ),
    );
  }
}
