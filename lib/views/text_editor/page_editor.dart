import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/page.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/services/authentication_service.dart';
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
  late QuillController _controller;
  late StreamSubscription _documentChangesSubscription;
  late StreamSubscription _pageSubscription;

  Page? page;

  @override
  void initState() {
    // Initialize controller
    _controller = QuillController.basic();
    // Listen to delta changes with _onLocalChange
    _documentChangesSubscription = _controller.document.changes.listen(_onLocalChange);
    // Listen to selection changes with _onSelectionChanged
    _controller.onSelectionChanged = _onSelectionChanged;
    // Listen to cloud document changes with _onRemoteChange
    _pageSubscription = ChapterEditService.pageStream('1', '1', widget.pageId).listen(_onRemoteChange);
    super.initState();
  }

  @override
  void dispose() {
    _pageSubscription.cancel();
    _documentChangesSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Currently totally replaces the document, initializing it again.
  void _updateDocumentWithDelta(Delta delta) {
    // Store current selection
    final selection = _controller.selection;
    // Cancel previous subscription to changes
    _documentChangesSubscription.cancel();
    // Initialize the document with the specified delta
    _controller.document = Document.fromDelta(delta);
    // Set selection to stored state
    _controller.updateSelection(selection, ChangeSource.LOCAL);
    // Restart subscription to changes
    _documentChangesSubscription = _controller.document.changes.listen(_onLocalChange);
  }

  void _onLocalChange(Tuple3<Delta, Delta, ChangeSource> event) {
    if (page == null) return;
    //
    int skip = 0;
    for (Operation op in event.item2.toList()) {
      if (op.isRetain) {
        skip += op.value as int;
      } else if (op.isInsert) {
        _onInsert(skip, op.value as String);
        break;
      } else if (op.isDelete) {
        _onDelete(skip, op.value as int);
        break;
        // Break out, because the an event never contains
        // two insert and/or delete operations. When iterating
        // the operations in an event's delta, if an insert is
        // reached, then it's guaranteed no inserts/deletes
        // are to follow.
        //
        // This is the same as saying the user can't ever delete
        // and insert in an unique event, even when he selects text
        // and writes. That scenaro, for example, would originate
        // two events instead. One for the delete operation, and
        // one for the insert operation.
      }
    }
  }

  /// Receive remote document change (Page object)
  ///
  /// * [page] Page object containing the new [snippets] and the [lastModifierUid]
  void _onRemoteChange(Page page) {
    // Ignore changes made by the user himself
    if (page.lastModifierUid == AuthenticationService.uid && this.page != null) return;
    Logs.d('Receiving $page');
    // Update page
    this.page = page;
    // Get page delta
    Delta delta = page.toDelta();
    // Append new line (to soothe the Quill Document =-=)
    delta.push(Operation.insert('\n'));
    // Update document with receiving data
    _updateDocumentWithDelta(delta);
  }

  void _onSelectionChanged(TextSelection selection) {
    //Logs.d('${selection.baseOffset}');
  }

  void _onInsert(int skip, String text) {
    Logs.d('onInsert($skip, $text)');
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
    //page!.snippets.removeWhere((s) => s.text.isEmpty);
    ChapterEditService.pageUpdate(page!, AuthenticationService.uid);
  }

  void _onDelete(int skip, int length) {
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
        String textAfter = snippet.text.substring(end, snippetLength);
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
    //page!.snippets.removeWhere((s) => s.text.isEmpty);
    ChapterEditService.pageUpdate(page!, AuthenticationService.uid);
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
