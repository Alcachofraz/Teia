import 'package:flutter/material.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippet_factory.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/views/misc/screen_wrapper.dart';

class ReadChapterScreen extends StatefulWidget {
  final Chapter chapter;
  const ReadChapterScreen({
    Key? key,
    required this.chapter,
  }) : super(key: key);

  @override
  State<ReadChapterScreen> createState() => _ReadChapterScreenState();
}

class _ReadChapterScreenState extends State<ReadChapterScreen> {
  int pageId = 0; // Get this from database
  tPage? page;

  @override
  void initState() {
    super.initState();
    ChapterManagementService.pageGet('1', '1', '1')
        .then((o) => setState(() => page = o));
  }

  /// Callback to when a choice is clicked.
  void onChoice(int choice) {
    print('On Choice $choice');
  }

  /// Callback to when an image is clicked.
  void onImage(String url) {
    print('On URL $url');
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      body: Column(
        children: [
          if (page != null)
            RichText(
              text: TextSpan(
                children: SnippetFactory.spansFromPage(
                  page!,
                  onImage,
                  onChoice,
                ),
              ),
            ),
          if (widget.chapter.isFinalPage(pageId))
            TextButton(
              onPressed: () {
                // Finish chapter
              },
              child: const Text(
                'Finish Chapter',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
