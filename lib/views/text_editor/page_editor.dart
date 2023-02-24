import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/page.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/text_editor/page_edititing_controller.dart';

class PageEditor extends StatefulWidget {
  final Page page;
  final Function(String)? onChanged;
  final Function(TextSelection, SelectionChangedCause?)? onSelectionChanged;
  final PageEditingController? controller;

  const PageEditor({
    super.key,
    required this.page,
    this.onChanged,
    this.onSelectionChanged,
    this.controller,
  });

  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _node,
      style: Utils.textEditorStyle,
      maxLines: null,
      minLines: null,
      decoration: const InputDecoration.collapsed(
        hintText: 'Once upon a time...',
      ),
    );
  }
}
