import 'dart:developer';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:teia/models/page.dart';

class TextEditor extends StatefulWidget {
  final Page page;
  const TextEditor({
    super.key,
    required this.page,
  });

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  final QuillController _controller = QuillController.basic();

  @override
  void initState() {
    _controller.onSelectionChanged = (selection) {
      if (selection.baseOffset != selection.extentOffset) {
        log(_controller.getPlainText());
      }
    };
    _controller.document = Document()..insert(0, widget.page.getRawText());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: QuillEditor.basic(
            controller: _controller,
            readOnly: false, // true for view only mode
          ),
        ),
      ],
    );
  }
}
