import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/views/misc/expandable_tile.dart';

class SnippetImageCard extends StatelessWidget {
  final Snippet snippet;
  const SnippetImageCard({
    super.key,
    required this.snippet,
  });

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
                width: 56.0,
                height: 56.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Image Snippet",
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    snippet.text,
                    style: GoogleFonts.roboto(
                      fontSize: 11.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
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
                "Image Snippet",
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8.0),
              Text(
                snippet.text,
                style: GoogleFonts.roboto(
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                ),
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
