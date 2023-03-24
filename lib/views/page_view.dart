import 'package:flutter/material.dart' hide Page;

class PageView extends StatefulWidget {
  //final Page page;
  final Function()? onChoice;
  final Function()? onImage;
  final Function()? onSecret;
  const PageView({
    super.key,
    //required this.page,
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
    /*for (Snippet snippet in widget.page.snippets) {
      if (snippet is TextSnippet) {
        snippets.add(TextSpan(text: snippet.text));
      } else if (snippet is ChoiceSnippet) {
        snippets.add(TextSpan(
          text: snippet.text,
          recognizer: TapGestureRecognizer()..onTap = widget.onChoice,
        ));
      } else if (snippet is TextSnippet) {
        snippets.add(TextSpan(
          text: snippet.text,
          recognizer: TapGestureRecognizer()..onTap = widget.onImage,
        ));
      }
    }*/
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
