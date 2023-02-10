import 'package:flutter/material.dart';
import 'package:teia/models/page.dart';
import 'package:teia/views/screen_wrapper.dart';

class ReadChapterScreen extends StatefulWidget {
  const ReadChapterScreen({Key? key}) : super(key: key);

  @override
  State<ReadChapterScreen> createState() => _ReadChapterScreenState();
}

class _ReadChapterScreenState extends State<ReadChapterScreen> {
  Widget _renderPage(TPage page) {}

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      body: Column(
        children: const [],
      ),
    );
  }
}
