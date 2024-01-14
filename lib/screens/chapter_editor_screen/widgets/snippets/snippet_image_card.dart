import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/views/misc/expandable_tile.dart';

class SnippetImageCard extends StatelessWidget {
  final Snippet snippet;
  const SnippetImageCard({
    Key? key,
    required this.snippet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandableTile(
      collapsed: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3.0),
              child: Image.network(
                snippet.attributes['url'],
                width: 48.0,
                height: 48.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choice Snippet",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '"${snippet.text}"',
                  style: GoogleFonts.roboto(fontSize: 14.0),
                ),
              ],
            ),
          ],
        ),
      ),
      expanded: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choice Snippet",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8.0),
              Text(
                '"${snippet.text}"',
                style: GoogleFonts.roboto(fontSize: 14.0),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.0),
                      child: Image.network(
                        snippet.attributes['url'],
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(4.0),
    );
  }
}
