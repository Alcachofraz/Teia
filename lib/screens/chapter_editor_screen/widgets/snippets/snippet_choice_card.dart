import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/views/misc/tile.dart';

class SnippetChoiceCard extends StatelessWidget {
  final Snippet snippet;
  final Function(int page) onPageTap;
  const SnippetChoiceCard({
    Key? key,
    required this.snippet,
    required this.onPageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tile(
      width: double.infinity,
      padding: EdgeInsets.zero,
      radiusAll: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choice Snippet",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                style: GoogleFonts.roboto(fontSize: 14.0),
                children: [
                  TextSpan(text: '"${snippet.text}"  🠪  '),
                  TextSpan(
                    text: 'Page ${snippet.attributes['choice']}',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        onPageTap(snippet.attributes['choice']);
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
