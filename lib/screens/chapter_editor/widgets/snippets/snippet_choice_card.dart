import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/views/misc/tile.dart';

class SnippetChoiceCard extends StatelessWidget {
  final Snippet snippet;
  final void Function()? removeSnippet;
  final Function(int page) onPageTap;
  const SnippetChoiceCard({
    super.key,
    required this.snippet,
    required this.onPageTap,
    this.removeSnippet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Tile(
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
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4.0),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.roboto(
                        fontSize: 11.0,
                        fontStyle: FontStyle.italic,
                      ),
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
          ),
        ),
        Gap(12),
        InkWell(
          onTap: removeSnippet,
          child: const Icon(
            Icons.delete,
            size: 24.0,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
