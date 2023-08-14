import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/image_snippet.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/screens/chapter_editor_screen/widgets/cursor/cursor_block_embed.dart';
import 'package:teia/screens/chapter_editor_screen/widgets/cursor/cursor_embed_builder.dart';
import 'package:teia/screens/chapter_editor_screen/widgets/remote_cursor.dart';
import 'package:teia/screens/chapter_editor_screen/widgets/snippets/snippet_choice_card.dart';
import 'package:teia/screens/chapter_editor_screen/widgets/snippets/snippet_image_card.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/logs.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/tap_icon.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:universal_html/html.dart';

class PageEditor extends StatefulWidget {
  final String pageId;
  final FocusNode? focusNode;
  final Future<void> Function(tPage page)? pushPageToRemote;
  final Future<void> Function(Chapter chapter)? pushChapterToRemote;
  final Size screenSize;
  final List<int> missingLinks;
  final Chapter chapter;
  final Function(int pageId) onPageTap;

  const PageEditor({
    super.key,
    required this.pageId,
    this.focusNode,
    this.pushPageToRemote,
    this.pushChapterToRemote,
    required this.screenSize,
    this.missingLinks = const [],
    required this.onPageTap,
    required this.chapter,
  });

  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  late QuillController _controller;
  late StreamSubscription _documentChangesSubscription;
  late StreamSubscription _pageSubscription;
  late ScrollController _scrollController;
  FocusNode focus = FocusNode();

  tPage? page;

  TextSelection? _selection;
  Snippet? _atSnippet;

  late double textEditorWeight;
  late double pageWeight;
  late double compensation;
  double _lineOffset = 24;

  List<int> missingLinks = [];
  bool showingChoiceOption = false;
  bool showingTextOption = false;
  bool showingImageOption = false;

  @override
  void initState() {
    // Scroll controller
    _scrollController = ScrollController();
    // Initialize controller
    _controller = QuillController.basic();
    // Listen to delta changes with _onLocalChange
    _documentChangesSubscription =
        _controller.document.changes.listen(_onLocalChange);
    // Listen to selection changes with _onSelectionChanged
    _controller.onSelectionChanged = _onSelectionChanged;
    // Listen to cloud document changes with _onRemoteChange
    _pageSubscription =
        ChapterManagementService.pageStream('1', '1', widget.pageId)
            .listen(_onRemoteChange);

    // Prevent default event handler
    document.onContextMenu.listen((event) => event.preventDefault());

    super.initState();
  }

  @override
  void dispose() {
    _pageSubscription.cancel();
    _documentChangesSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pushChapterToRemote(Chapter chapter) async {
    //Logs.d('Sending:\n${chapter.toString()}');
    if (widget.pushChapterToRemote != null) {
      await widget.pushChapterToRemote!(widget.chapter);
    }
  }

  Future<void> _pushPageToRemote(tPage? page) async {
    //Logs.d('Sending:\n${page.toString()}');
    if (widget.pushPageToRemote != null && page != null) {
      await widget.pushPageToRemote!(page);
    }
  }

  void _replaceDelta(Delta currentDelta, Delta newDelta) {
    Delta diff = currentDelta.diff(newDelta);
    _controller.compose(
      diff,
      const TextSelection(baseOffset: 0, extentOffset: 0),
      ChangeSource.REMOTE,
    );
  }

  void _updateLineOffset(String textUntilCursor) {
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: Utils.textEditorStyle,
        text: textUntilCursor,
      ),
    );
    painter.layout();

    _lineOffset = painter.height;
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
  void _onLocalChange(DocChange change) {
    // If not page yet or change is remote, do nothing
    if (page == null || change.source == ChangeSource.REMOTE) return;
    // Characters to skip.
    int skip = 0;
    // Iterate all operations
    //log(change.change.toList().toString());
    for (Operation op in change.change.toList()) {
      if (op.isRetain) {
        // If retaining, add to skip
        if (op.attributes != null && op.attributes!['color'] == null) {
          _onNeglectSnippet(skip, op.length ?? 0);
        }
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
  void _onRemoteChange(tPage page) {
    bool firstFetch = this.page == null;
    if (firstFetch) {
      Delta delta = page.toDelta();
      if (delta.isNotEmpty) {
        _controller.compose(
          delta,
          const TextSelection(baseOffset: 0, extentOffset: 0),
          ChangeSource.REMOTE,
        );
        // Move cursor to document end
        _controller.moveCursorToEnd();
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

  void _onNeglectSnippet(int skip, int length) {
    //Logs.d('Inserting($skip, $text)');
    if (page == null) {
      Logs.e('Trying to insert on a null Page!');
      return;
    }
    page!.forgetSnippets(skip, length);
    //page!.normalizeSnippets();
    _pushPageToRemote(page);
  }

  void _onSelectionChanged(TextSelection selection) {
    if (selection.baseOffset != selection.extentOffset) {
      // Selecting text
      setState(() {
        _atSnippet = null;
        _selection = selection;
        /*_updateLineOffset();*/
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
    //_controller.formatSelection(const ColorAttribute('#000000'));
  }

  void _onAddImage() {
    if (_selection == null) return;
    Delta currentDelta = page!.toDelta();
    page!.createSnippet(_selection!.baseOffset, _selection!.extentOffset - 1,
        url: 'https://picsum.photos/200');
    _replaceDelta(currentDelta, page!.toDelta());
    _pushPageToRemote(page);
  }

  void _onAddChoice([int? id]) async {
    if (_selection == null) return;
    Delta currentDelta = page!.toDelta();
    id ??= widget.chapter.addPage(page!.id);
    page!.createSnippet(_selection!.baseOffset, _selection!.extentOffset - 1,
        choice: id);
    _replaceDelta(currentDelta, page!.toDelta());
    widget.chapter.addLink(page!.id, childId: id);
    await _pushChapterToRemote(widget.chapter);
    await _pushPageToRemote(page);
  }

  Widget _snippetCard(Snippet snippet, String text) {
    if (snippet is ImageSnippet) {
      return SnippetImageCard(snippet: snippet, text: text);
    }
    if (snippet is ChoiceSnippet) {
      return SnippetChoiceCard(
          snippet: snippet, text: text, onPageTap: widget.onPageTap);
    }
    return const SizedBox.shrink();
  }

  Widget _comments() {
    String text = '';
    if (_atSnippet != null) {
      // Get text of Snippet
      for (var letter in page!.letters) {
        if (letter.id.compareTo(_atSnippet!.from) >= 0) {
          text += letter.letter;
        }
        if (letter.id.compareTo(_atSnippet!.to) >= 0) {
          break;
        }
      }
    }
    return Column(
      children: [
        if (_atSnippet != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: _snippetCard(_atSnippet!, text),
          ),
        // for() comments
      ],
    );
  }

  Widget _textOptions() {
    var lelftmargin = (((widget.screenSize.width * textEditorWeight) -
                (Utils.collapseButtonSize * (pageWeight == 1 ? 2 : 1))) *
            pageWeight) -
        Utils.textOptionsWidth / 2;
    return Positioned(
      left: lelftmargin,
      top: _lineOffset,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selection != null
            ? Tile(
                padding: EdgeInsets.zero,
                radiusAll: 64,
                elevation: 8,
                width: Utils.textOptionsWidth,
                color: Colors.white,
                child: Column(
                  children: [
                    JustTheTooltip(
                      waitDuration: const Duration(milliseconds: 1000),
                      content: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Add a page link',
                        ),
                      ),
                      child: TapIcon(
                        backgroundColor: Colors.white,
                        icon: const Icon(
                          Icons.add_link,
                        ),
                        onTap: () {
                          setState(() {
                            showingChoiceOption = !showingChoiceOption;
                            showingImageOption = false;
                          });
                          //_onAddChoice();
                        },
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: !showingChoiceOption
                          ? const SizedBox.shrink()
                          : Tile(
                              padding: EdgeInsets.zero,
                              radiusAll: 64,
                              elevation: 4,
                              width: Utils.textOptionsWidth - 8,
                              color: Colors.grey[50],
                              child: Column(
                                children: [
                                  for (int id in widget.chapter.graph
                                      .nodes[int.parse(widget.pageId)]!)
                                    InkWell(
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(128),
                                      ),
                                      child: Container(
                                        width: Utils.textOptionsWidth - 8,
                                        height: Utils.textOptionsWidth - 8,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(128),
                                        ),
                                        child: Center(
                                          child: Text(
                                            id.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: missingLinks.contains(id)
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          showingChoiceOption = false;
                                        });
                                        _onAddChoice(id);
                                      },
                                    ),
                                  TapIcon(
                                    backgroundColor: Colors.transparent,
                                    icon: const Icon(
                                      Icons.add,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        showingChoiceOption = false;
                                      });
                                      _onAddChoice();
                                    },
                                  )
                                ],
                              ),
                            ),
                    ),
                    JustTheTooltip(
                      waitDuration: const Duration(milliseconds: 1000),
                      content: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Add an image link',
                        ),
                      ),
                      child: TapIcon(
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                        ),
                        onTap: () {
                          setState(() {
                            showingImageOption = !showingImageOption;
                            showingChoiceOption = false;
                          });
                        },
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: !showingImageOption
                          ? const SizedBox.shrink()
                          : Tile(
                              padding: EdgeInsets.zero,
                              radiusAll: 64,
                              elevation: 4,
                              width: Utils.textOptionsWidth - 8,
                              color: Colors.grey[100],
                              child: Column(
                                children: [
                                  TapIcon(
                                    backgroundColor: Colors.transparent,
                                    icon: const Icon(
                                      Icons.brush_rounded,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        showingImageOption = false;
                                      });
                                      /* Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ImageEditorScreen()),
                                      );*/
                                      _onAddImage();
                                    },
                                  ),
                                  TapIcon(
                                    backgroundColor: Colors.transparent,
                                    icon: const Icon(
                                      Icons.upload_rounded,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        showingImageOption = false;
                                      });
                                      // Load image from device
                                    },
                                  ),
                                ],
                              ),
                            ),
                    ),
                    JustTheTooltip(
                      waitDuration: const Duration(milliseconds: 1000),
                      content: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Add a comment',
                        ),
                      ),
                      child: TapIcon(
                        icon: const Icon(
                          Icons.comment_outlined,
                        ),
                        onTap: () {
                          setState(() {
                            showingImageOption = false;
                            showingChoiceOption = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(
                key: ValueKey<int>(1),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    textEditorWeight = (widget.screenSize.width < Utils.maxWidthShowOnlyEditor)
        ? 1.0
        : Utils.editorWeight;
    pageWeight = (widget.screenSize.width < Utils.maxWidthShowOnlyEditorPage)
        ? 1.0
        : Utils.editorPageWeight;
    compensation = pageWeight == 1.0
        ? Utils.collapseButtonSize - Utils.textOptionsWidth / 2
        : -Utils.textOptionsWidth / 2;

    missingLinks.clear();
    int pageId = int.parse(widget.pageId);
    for (int id in widget.chapter.graph.nodes[pageId]!) {
      if (!widget.chapter.links.nodes[pageId]!.contains(id)) {
        missingLinks.add(id);
      }
    }

    return page == null
        ? loadingRotate()
        : Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: Utils.editorPageWeight * 100 as int,
                    child: Tile(
                      elevation: 2.5,
                      padding: EdgeInsets.zero,
                      color: Utils.pageEditorSheetColor,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  24.0, 24.0, 24.0, 24.0),
                              child: QuillEditor(
                                controller: _controller,
                                readOnly: false,
                                expands: true,
                                paintCursorAboveText: true,
                                placeholder: 'Once upon a time...',
                                scrollable: true,
                                autoFocus: true,
                                focusNode: focus,
                                padding: const EdgeInsets.fromLTRB(
                                    24.0, 20.0, 24.0, 24.0),
                                scrollController: _scrollController,
                                onImagePaste: (bytes) => Future.value(null),
                                onLaunchUrl: null,
                                embedBuilders: [CursorEmbedBuilder()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  widget.screenSize.width > Utils.maxWidthShowOnlyEditorPage
                      ? Expanded(
                          flex: (1 - Utils.editorPageWeight) * 100 as int,
                          child: _comments(),
                        )
                      : const SizedBox(
                          width: Utils.collapseButtonSize,
                        )
                ],
              ),
              _textOptions(),
            ],
          );
  }
}
