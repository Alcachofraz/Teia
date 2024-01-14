import 'package:flutter/material.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippet_factory.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';

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
    final screenSize = MediaQuery.of(context).size;
    return ScreenWrapper(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: screenSize.width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: screenSize.height * 0.03),
                Text(
                  widget.chapter.title,
                  style: const TextStyle(
                    fontSize: 28.0,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Expanded(
                  child: Tile(
                    width: double.infinity,
                    elevation: 2.5,
                    padding: EdgeInsets.zero,
                    color: Utils.pageEditorSheetColor,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (page != null)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 28, 24, 24),
                              child: RichText(
                                text: TextSpan(
                                    style: Utils.textReadingStyle,
                                    children: /*SnippetFactory.spansFromPage(
                                    page!,
                                    onImage,
                                    onChoice,
                                  ),*/
                                        null),
                              ),
                            ),
                          if (widget.chapter.isFinalPage(pageId))
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: TextButton(
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
                            ),
                          SizedBox(height: screenSize.height * 0.01),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
