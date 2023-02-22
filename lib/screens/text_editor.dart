import 'dart:developer';

import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/page.dart';
import 'package:fleather/fleather.dart';

class TextEditor extends StatefulWidget {
  final Page page;
  final Function(String)? onChanged;
  final Function(TextSelection, SelectionChangedCause?)? onSelectionChanged;

  const TextEditor({
    super.key,
    required this.page,
    this.onChanged,
    this.onSelectionChanged,
  });

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  //final TextEditingController _controller = TextEditingController();
  final FocusNode _node = FocusNode();
  final FleatherController _controller = FleatherController();

  @override
  void initState() {
    /*_controller.addListener(() {
      log('Listener!');
    });*/
    _controller.addListener(() {
      log('Listener!');
    });
    super.initState();
  }

  @override
  void dispose() {
    //_controller.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FleatherEditor(controller: _controller);
    /*return TextField(
      controller: _controller,
      focusNode: _node,
      style: Utils.textEditorStyle,
      maxLines: null,
      minLines: null,
      decoration: const InputDecoration.collapsed(
        hintText: 'Once upon a time...',
      ),
    );*/
  }
}
