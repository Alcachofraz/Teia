import 'package:flutter/material.dart';
import 'package:teia/models/chapter.dart';
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

  @override
  void initState() {
    super.initState();
  }

  /// Callback to when a choice is clicked.
  void onChoice(int newPageId) {}

  /// Callback to when a choice is clicked.
  void onImage(String url) {}

  /// Callback to when a choice is clicked.
  void onSecret(String secret) {}

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      body: Column(
        children: [
          PageView(),
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
