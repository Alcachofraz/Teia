import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:teia/views/screen_wrapper.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({super.key});

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      body: QuillEditor.basic(
        controller: _controller,
        readOnly: false, // true for view only mode
      ),
    );
  }
}
