import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/editing_page.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_edit_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/logs.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:teia/views/text_editor/cursor_block_embed.dart';
import 'package:teia/views/text_editor/cursor_embed_builder.dart';
import 'package:teia/views/text_editor/remote_cursor.dart';
import 'package:tuple/tuple.dart';

class PageEditor extends StatefulWidget {
  final String pageId;
  final FocusNode? focusNode;
  final Function(EditingPage page)? pushPageToRemote;

  const PageEditor({
    super.key,
    required this.pageId,
    this.focusNode,
    this.pushPageToRemote,
  });

  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  late QuillController _controller;
  late StreamSubscription _documentChangesSubscription;
  late StreamSubscription _pageSubscription;
  late ScrollController _scrollController;

  EditingPage? page;

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

  void _pushPageToRemote(EditingPage? page) {
    //Logs.d('Sending:\n${page.toString()}');
    if (widget.pushPageToRemote != null && page != null) widget.pushPageToRemote!(page);
  }

  void _replaceDelta(Delta currentDelta, Delta newDelta) {
    Delta diff = currentDelta.diff(newDelta);
    _controller.compose(
      diff,
      const TextSelection(baseOffset: 0, extentOffset: 0),
      ChangeSource.REMOTE,
    );
  }

  void _updateRemoteCursors(List<RemoteCursor> cursors) {
    for (RemoteCursor cursor in cursors) {
      final block = BlockEmbed.custom(
        CursorBlockEmbed.fromDocument(cursor.toString()),
      );
      _controller.replaceText(cursor.index, 0, block, null);
    }
  }

  /// Receive local document change.
  ///
  /// * [event] A tuple containing the deltas and change source.
  void _onLocalChange(Tuple3<Delta, Delta, ChangeSource> event) {
    // If not page yet or change is remote, do nothing
    if (page == null || event.item3 == ChangeSource.REMOTE) return;
    // Characters to skip.
    int skip = 0;
    // Iterate all operations
    for (Operation op in event.item2.toList()) {
      if (op.isRetain) {
        // If retaining, add to skip
        skip += op.value as int;
      } else if (op.isInsert) {
        // If inserting, call _onInsert() with current skip
        String text = op.value as String;
        _onInsert(skip, text);
        // Add he inserted text length to skip
        skip += text.length;
      } else if (op.isDelete) {
        // If deleting, call _onDelete() with current skip
        int length = op.value as int;
        _onDelete(skip, length);
        // Remove the deleting text length from skip
        skip -= length;
      }
    }
  }

  /// Receive remote document change (Page object).
  ///
  /// * [page] Page object containing the new [snippets] and the [lastModifierUid]
  void _onRemoteChange(EditingPage page) {
    bool firstFetch = this.page == null;
    if (firstFetch) {
      Delta delta = page.toDelta();
      if (delta.isNotEmpty) {
        _controller.compose(
          delta,
          const TextSelection(baseOffset: 0, extentOffset: 0),
          ChangeSource.REMOTE,
        );
      }
      setState(() {});
    } else if (page.lastModifierUid == AuthenticationService.uid) {
      return;
    } else {
      _replaceDelta(this.page!.toDelta(), page.toDelta());
    }
    this.page = page;
  }

  /// On document insert.
  void _onInsert(int skip, String text) {
    //Logs.d('Inserting($skip, $text)');
    if (page == null) {
      Logs.e('Trying to insert on a null Page!');
      return;
    }
    page!.insert(skip, text);
    //page!.normalizeSnippets();
    _pushPageToRemote(page);
  }

  /// On document delete.
  void _onDelete(int skip, int length) {
    //Logs.d('Deleting($skip, $length)');
    if (page == null) {
      Logs.e('Trying to insert on a null Page!');
      return;
    }
    page!.delete(skip, length);
    //page!.normalizeSnippets();
    _pushPageToRemote(page);
  }

  void _onSelectionChanged(TextSelection selection) {
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
        _atSnippet = page!.findSnippetByIndex(selection.baseOffset);
      });
    }
  }

  void _onAddChoice() {
    if (_selection == null) return;
    Delta currentDelta = page!.toDelta();
    page!.createSnippet(_selection!.baseOffset, _selection!.extentOffset - 1, url: '');
    _replaceDelta(currentDelta, page!.toDelta());
    _pushPageToRemote(page);
  }

  void _onAddImage() {
    if (_selection == null) return;
    Delta currentDelta = page!.toDelta();
    page!.createSnippet(_selection!.baseOffset, _selection!.extentOffset - 1, id: 0);
    _replaceDelta(currentDelta, page!.toDelta());
    _pushPageToRemote(page);
  }

  Widget _textOptions() {
    return Stack(
      children: const [],
    );

    /*Column(
      children: [
        Tile(
          color: _selection == null ? Colors.grey[100]! : Utils.pageEditorSheetColor,
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 24.0, 0.0),
          onTap: _selection == null
              ? null
              : () {
                  _onAddChoice();
                },
          child: Row(
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Add Choice'),
                ),
              ),
            ],
          ),
        ),
        Tile(
          color: _selection == null ? Colors.grey[100]! : Utils.pageEditorSheetColor,
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 24.0, 0.0),
          onTap: _selection == null
              ? null
              : () {
                  _onAddImage();
                },
          child: Row(
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Add Image'),
                ),
              ),
            ],
          ),
        ),
        if (_atSnippet != null)
          Tile(
            color: Utils.pageEditorSheetColor,
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 24.0, 0.0),
            child: Row(
              children: const [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('At Snippet'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );*/
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
              : Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.text,
                        child: Tile(
                          elevation: 2.5,
                          padding: EdgeInsets.zero,
                          color: Utils.pageEditorSheetColor,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(48.0, 44.0, 48.0, 48.0),
                            child: QuillEditor(
                              controller: _controller,
                              readOnly: false,
                              expands: true,
                              autoFocus: false,
                              focusNode: widget.focusNode ?? FocusNode(),
                              padding: EdgeInsets.zero,
                              scrollable: true,
                              scrollController: _scrollController,
                              onImagePaste: (bytes) => Future.value(null),
                              onLaunchUrl: null,
                              embedBuilders: [CursorEmbedBuilder()],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _textOptions(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
