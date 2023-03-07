import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/page.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_edit_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/logs.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/tile.dart';
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
  final FocusNode _focusNodes = FocusNode();
  late QuillController _controller;
  late StreamSubscription _documentChangesSubscription;
  late StreamSubscription _pageSubscription;
  late ScrollController _scrollController;

  Page? page;

  TextSelection? _selection;
  Snippet? _atSnippet;

  @override
  void initState() {
    // Scroll controller
    _scrollController = ScrollController();
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
  void _updateDocumentWithDelta(Delta delta, bool firstFecth) {
    // Store current selection
    final selection = _controller.selection;
    // Cancel previous subscription to changes
    _documentChangesSubscription.cancel();
    // Initialize the document with the specified delta
    _controller.document = Document.fromDelta(delta);
    // Set selection to stored state
    if (firstFecth) {
      _controller.moveCursorToEnd();
    } else {
      _controller.updateSelection(selection, ChangeSource.LOCAL);
    }
    // Restart subscription to changes
    _documentChangesSubscription = _controller.document.changes.listen(_onLocalChange);
  }

  /// Receive local document change.
  ///
  /// * [event] A tuple containing the deltas and change source.
  void _onLocalChange(Tuple3<Delta, Delta, ChangeSource> event) {
    if (page == null) return;
    // Characters to skip.
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

  /// Receive remote document change (Page object).
  ///
  /// * [page] Page object containing the new [snippets] and the [lastModifierUid]
  void _onRemoteChange(Page page) {
    // Ignore changes made by the user himself, as long
    // as it's not the first fetch.
    // If current editing page is null, it's the first fetch
    bool firstFecth = this.page == null;
    if (page.lastModifierUid == AuthenticationService.uid && !firstFecth) return;
    // Update page
    this.page = page;
    // Get page delta
    Delta delta = page.toDelta();
    // Append new line (to soothe the Quill Document =-=)
    delta.push(Operation.insert('\n'));
    // Update document with receiving data
    _updateDocumentWithDelta(delta, firstFecth);

    if (firstFecth) setState(() {});
  }

  /// On document insert.
  void _onInsert(int skip, String text) {
    if (page == null) {
      Logs.e('Trying to insert on a null Page!');
      return;
    }
    page!.insert(skip, text);
    //page!.snippets.removeWhere((s) => s.text.isEmpty);
    ChapterEditService.pageUpdate(page!, AuthenticationService.uid);
  }

  /// On document delete.
  void _onDelete(int skip, int length) {
    if (page == null) {
      Logs.e('Trying to insert on a null Page!');
      return;
    }
    page!.delete(skip, length);
    //page!.snippets.removeWhere((s) => s.text.isEmpty);
    ChapterEditService.pageUpdate(page!, AuthenticationService.uid);
  }

  void _onSelectionChanged(TextSelection selection) {
    //Logs.d('${selection.baseOffset}');
    if (selection.baseOffset != selection.extentOffset) {
      // Selecting text
      setState(() {
        _atSnippet = null;
        _selection = selection;
      });
    } else {
      // Positioning cursor
      if (page == null) return;
      // Find local snippet
      setState(() {
        _selection = null;
        _atSnippet = page!.findSnippet(selection.baseOffset);
      });
    }
  }

  void _onAddChoice() {
    page!.createSnippet(_selection!.baseOffset, _selection!.extentOffset, url: '');
  }

  void _onAddImage() {
    page!.createSnippet(_selection!.baseOffset, _selection!.extentOffset, id: 0);
  }

  Widget _textSelectionOptions() => Tile(
        padding: EdgeInsets.zero,
        color: Utils.graphSettings.backgroundColor,
        elevation: 0.0,
        radiusTopLeft: 16.0,
        radiusTopRight: 16.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              Tile(
                radiusAll: 100,
                color: Colors.white,
                onTap: _onAddChoice,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text('Choice'),
                ),
              ),
              Tile(
                radiusAll: 100,
                color: Colors.white,
                onTap: _onAddImage,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text('Image'),
                ),
              ),
            ],
          ),
        ),
      );

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
              color: Utils.graphSettings.nodeBorderColor,
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
          child: page == null
              ? loadingRotate()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                  child: MouseRegion(
                    //cursor: SystemMouseCursors.text,
                    child: QuillEditor(
                      controller: _controller,
                      readOnly: false,
                      expands: true,
                      autoFocus: false,
                      focusNode: _focusNodes,
                      padding: EdgeInsets.zero,
                      scrollable: true,
                      scrollController: _scrollController,
                      onImagePaste: (bytes) => Future.value(null),
                    ),
                  ),
                ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.decelerate,
          child: _selection != null
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(child: _textSelectionOptions()),
                  ],
                )
              : Row(
                  children: const [
                    SizedBox.shrink(),
                  ],
                ),
        ),
      ],
    );
  }
}
