import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/page.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/services/chapter_edit_service.dart';
import 'package:teia/utils/logs.dart';
import 'package:teia/utils/utils.dart';
import 'dart:math' as math;
import 'package:tuple/tuple.dart';

class PageEditor extends StatefulWidget {
  final String pageId;

  const PageEditor({
    super.key,
    required this.pageId,
  });

  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  final FocusNode _node = FocusNode();
  late QuillController _controller;
  late StreamSubscription _documentChangesSubscription;
  late StreamSubscription _pageSubscription;

  Page? page;

  @override
  void initState() {
    _controller = QuillController.basic();
    _documentChangesSubscription = _controller.document.changes.listen(onLocalChange);
    _controller.onSelectionChanged = onSelectionChanged;
    _pageSubscription = ChapterEditService.pageStream('1', '1', widget.pageId).listen((page) {
      onRemoteChange(page);
    });
    super.initState();
  }

  @override
  void dispose() {
    _documentChangesSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  void onLocalChange(Tuple3<Delta, Delta, ChangeSource> event) {
    if (event.item3 == ChangeSource.REMOTE) return;
    if (page == null) return;
    int skip = 0;
    for (Operation op in event.item2.toList()) {
      if (op.isRetain) {
        skip += op.value as int;
      } else if (op.isInsert) {
        onInsert(skip, op.value as String);
      } else if (op.isDelete) {
        onDelete(skip, op.value as int);
      }
    }
  }

  void onRemoteChange(Page page) {
    this.page = page;
    Operation clear = Operation.delete(_controller.document.length);
    Delta delta = Delta.fromOperations([clear]);
    delta.concat(page.toDelta());
    _controller.document.compose(delta, ChangeSource.REMOTE);
    page.toDelta();
  }

  void onSelectionChanged(TextSelection selection) {
    //Logs.d('${selection.baseOffset}');
  }

  void onInsert(int skip, String text) {
    if (page == null) {
      Logs.e('Trying to insert on a null Page!');
      return;
    }
    int aux = 0; // Current snippet first character index
    for (Snippet snippet in page!.snippets) {
      // Length of current snippet
      int snippetLength = snippet.text.length;
      if (skip >= aux && skip <= aux + snippetLength) {
        // If skip (number of characters to skip before start inserting), is
        // inside this snippet ([aux + snippetLength] is the last character
        // of this snippet)

        // Text before the text to insert
        String textBefore = snippet.text.substring(0, skip - aux);
        // Text after the text to insert
        String textAfter = snippet.text.substring(skip - aux, snippetLength);
        // Concatenate and assign all text
        snippet.text = textBefore + text + textAfter;
        break;
      }
      aux += snippetLength;
    }
    page!.snippets.removeWhere((s) => s.text.isEmpty);
    ChapterEditService.updatePage(page!);
  }

  void onDelete(int skip, int length) {
    if (page == null) {
      Logs.e('Trying to insert on a null Page!');
      return;
    }
    int aux = 0; // Current snippet first character index
    int deleted = 0; // Deleted characters so far
    for (Snippet snippet in page!.snippets) {
      int snippetLength = snippet.text.length; // Current snippet length
      if (deleted != 0) {
        // If already started deleting

        // Index of last character to remove in THIS SNIPPET
        int end = math.min(length - deleted, snippetLength);
        // Remove designated text
        snippet.text = snippet.text.substring(end, snippetLength);
        // Update deleted
        deleted += end;
      } else if (skip >= aux && skip <= aux + snippetLength) {
        // If skip (number of characters to skip before start deleting), is
        // inside this snippet ([aux + snippetLength] is the last character
        // of this snippet)

        // Index of first character to remove
        int start = skip - aux;
        // Text before the text to remove (to keep)
        String textBefore = snippet.text.substring(0, start);
        // Index of last character to remove in THIS SNIPPET
        int end = math.min(start + length, snippetLength);
        // Text before the text to remove (to keep)
        String textAfter = snippet.text.substring(start + 1, end);
        // Concatenate and assign all text to keep
        snippet.text = textBefore + textAfter;
        // Update deleted
        deleted += end - start;
      }
      // If already deleted all, break out
      if (deleted == length) break;
      // Increment aux to next snippet
      aux += snippetLength;
    }
    page!.snippets.removeWhere((s) => s.text.isEmpty);
    ChapterEditService.updatePage(page!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 18.0, 16.0, 0.0),
          child: Text(
            'Page ${widget.pageId}',
            style: TextStyle(
              color: Utils.nodeBorderColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
          child: Divider(),
        ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: QuillEditor.basic(
                controller: _controller,
                readOnly: false,
              )),
        ),
      ],
    );
  }
}
