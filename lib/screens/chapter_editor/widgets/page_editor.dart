import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/screens/chapter_editor/widgets/chat_gpt_view.dart';
import 'package:teia/screens/chapter_editor/widgets/cursor/cursor_embed_builder.dart';
import 'package:teia/screens/chapter_editor/widgets/snippets/snippet_choice_card.dart';
import 'package:teia/screens/chapter_editor/widgets/snippets/snippet_image_card.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/services/storage_service.dart';
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
  late StreamSubscription _localChangesSubscription;
  late StreamSubscription _pageChangesSubscription;
  late StreamSubscription _pageSubscription;
  late StreamSubscription _onContextMenu;
  late ScrollController _scrollController;
  FocusNode focus = FocusNode();

  late tPage page;

  TextSelection? _selection;
  Snippet? _atSnippet;

  late double textEditorWeight;
  late double pageWeight;
  late double compensation;
  final double _lineOffset = 24;

  List<int> missingLinks = [];
  bool showingChoiceOption = false;
  bool showingTextOption = false;
  bool showingImageOption = false;
  late int _sessionStartTimestamp;

  final ChapterManagementService chapterManagementService =
      Get.put(ChapterManagementService());

  final StorageService storageService = Get.put(StorageService());

  @override
  void initState() {
    page = tPage(1, 1, '1', SortedList<Letter>(), null, {});
    _sessionStartTimestamp = DateTime.now().millisecondsSinceEpoch;
    // Scroll controller
    _scrollController = ScrollController();
    // Initialize controller
    _controller = QuillController.basic();

    // Listen to delta changes with _onLocalChange
    _localChangesSubscription =
        _controller.document.changes.listen(_onLocalChange);
    // Listen to selection changes with _onSelectionChanged
    _controller.onSelectionChanged = _onSelectionChanged;

    // Prevent default event handler
    _onContextMenu =
        document.onContextMenu.listen((event) => event.preventDefault());

    _pageChangesSubscription = chapterManagementService
        .streamPageChanges('1', '1', '1')
        .listen(_onRemoteChange);

    _pageSubscription = chapterManagementService
        .pageStream('1', '1', '1')
        .listen(_onPageChange);

    super.initState();
  }

  @override
  void dispose() {
    _pageChangesSubscription.cancel();
    _localChangesSubscription.cancel();
    _pageSubscription.cancel();
    _controller.dispose();
    _onContextMenu.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pushChapterToRemote(Chapter chapter) async {
    //Logs.d('Sending:\n${chapter.toString()}');

    if (widget.pushChapterToRemote != null) {
      await widget.pushChapterToRemote!(widget.chapter);
    }
  }

  Future<void> _pushPageToRemote(tPage? page) async {
    //Logs.d('Sending:\n${page?.getRawText()}');
    if (widget.pushPageToRemote != null && page != null) {
      await widget.pushPageToRemote!(page);
    }
  }

  /*void _replaceDelta(Delta currentDelta, Delta newDelta) {
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
  }*/

  /*void _updateRemoteCursors(List<RemoteCursor> cursors) {
    for (RemoteCursor cursor in cursors) {
      final block = BlockEmbed.custom(
        CursorBlockEmbed.fromDocument(cursor.toString()),
      );
      _controller.replaceText(cursor.index, 0, block, null);
    }
  }*/

  /// Receive local document change.
  ///
  /// * [event] A tuple containing the deltas and change source.
  void _onLocalChange(DocChange change) {
    // If not page yet or change is remote, do nothing
    if (change.source == ChangeSource.remote) return;
    // Characters to skip.
    int skip = 0;
    // Iterate all operations
    //log(change.change.toList().toString());
    for (Operation op in change.change.toList()) {
      if (op.isRetain) {
        // If retaining, add to skip
        /*if (op.attributes != null && op.attributes!['color'] == null) {
          _onNeglectSnippet(skip, op.length ?? 0);
        }*/
        skip += op.value as int;
      } else if (op.isInsert) {
        // If inserting, call _onInsert() with current skip
        String text = op.value as String;
        _onLocalInsert(skip == 0 ? null : page.letters[skip - 1].id, text);
        // Add he inserted text length to skip
        skip += text.length;
      } else if (op.isDelete) {
        // If deleting, call _onDelete() with current skip
        int length = op.value as int;
        _onLocalDelete(page.letters[skip].id, length);
        // Remove the deleting text length from skip
        skip -= length;
      }
    }
  }

  void _onPageChange(tPage newPage) {
    page.updateWith(newPage);
  }

  void _onRemoteChange(Change change) {
    if (change.uid == AuthenticationService.value.uid &&
        change.timestamp > _sessionStartTimestamp) {
      return;
    }
    //print('Remote -> ${change.toString()}');

    Delta delta = page.compose(change);
    //print('New Page (letters) -> ${page.letters.toString()}');
    //print('DELTA -> ${delta.toJson()}');
    if (change.type == ChangeType.format) {
      _controller.formatText(
        page.letters.indexWhere((p0) => p0.id == change.id),
        change.length!,
        ColorAttribute(
          '#${colorToHex(Colors.blue)}', // Set color to blue - snippet
        ),
      );
    } else {
      _controller.compose(
        delta,
        const TextSelection(baseOffset: 0, extentOffset: 0),
        ChangeSource.remote,
      );
    }
  }

  /// On document insert.
  void _onLocalInsert(LetterId? id, String text) {
    //print('INSERT [$id, $text]');
    page.insert(id, text);
    chapterManagementService.pushPageChange(
      '1',
      '1',
      '1',
      Change(
        id,
        ChangeType.insert,
        AuthenticationService.value.uid ?? '-1',
        DateTime.now().millisecondsSinceEpoch,
        letter: text,
      ),
      cursorPosition: _controller.selection.end,
    );
  }

  /// On document delete.
  void _onLocalDelete(LetterId? id, int length) {
    //print('DELETE [$id, $length]');
    page.delete(id, length);
    chapterManagementService.pushPageChange(
      '1',
      '1',
      '1',
      Change(
        id,
        ChangeType.delete,
        AuthenticationService.value.uid ?? '-1',
        DateTime.now().millisecondsSinceEpoch,
        length: length,
      ),
      cursorPosition: _controller.selection.end,
    );
  }

  /// On document delete.
  void _onLocalFormat(LetterId? id, int length, Snippet snippet) {
    //print('FORMAT [$id, $length, $snippet]');
    page.format(id, length, snippet);
    chapterManagementService.pushPageChange(
      '1',
      '1',
      '1',
      Change(
        id,
        ChangeType.format,
        AuthenticationService.value.uid ?? '-1',
        DateTime.now().millisecondsSinceEpoch,
        length: length,
        snippet: snippet,
      ),
      cursorPosition: _controller.selection.end,
    );
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
      _controller.formatSelection(
        ColorAttribute(
          '#${colorToHex(Colors.black)}', // Set color to black - in case middle of a snippet
        ),
      );
      setState(() {
        _selection = null;
        _atSnippet = page.findSnippetByIndex(selection.baseOffset);
      });
    }
  }

  void _createSnippet(Snippet snippet) {
    // 1. and 3.
    _onLocalFormat(page.letters[_selection!.baseOffset].id,
        _selection!.extentOffset - _selection!.baseOffset, snippet);
    // 2.
    _controller.formatSelection(
      ColorAttribute(
        '#${colorToHex(Colors.blue)}', // Set color to blue - snippet
      ),
    );
  }

  Future<void> _onAddImage(Uint8List image) async {
    _createSnippet(Snippet(
      _selection!.textInside(_controller.document.toPlainText()),
      SnippetType.image,
      {
        'url': await storageService.uploadImage(
            widget.chapter.storyId, widget.chapter.id.toString(), image),
      },
    ));
  }

  void _onAddChoice([int? id]) async {
    if (_selection == null) return;
    // If id is null, create a new page and get its id
    id ??= widget.chapter.addPage(page.id);

    // Add link from this page to [id], in chapter, and push to remote
    widget.chapter.addLink(page.id, childId: id);
    await _pushChapterToRemote(widget.chapter);

    // Create the snippet
    _createSnippet(Snippet(
      _selection!.textInside(_controller.document.toPlainText()),
      SnippetType.choice,
      {'choice': id},
    ));
  }

  Widget _snippetCard(Snippet snippet) {
    switch (snippet.type) {
      case SnippetType.choice:
        return SnippetChoiceCard(snippet: snippet, onPageTap: widget.onPageTap);

      case SnippetType.image:
        return SnippetImageCard(snippet: snippet);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _comments() {
    return Column(
      children: [
        if (_atSnippet != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _snippetCard(_atSnippet!),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: ChatGPTView(
            getPageContent: () => _controller.document.toPlainText(),
          ),
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
                                    onTap: () async {
                                      setState(() {
                                        showingImageOption = false;
                                      });
                                      var image = await Get.toNamed(
                                        '/chapter_editor/generate',
                                      );
                                      if (image != null) {
                                        await _onAddImage(image);
                                      }
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

    return Stack(
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
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
                        child: QuillEditor(
                          configurations: QuillEditorConfigurations(
                            controller: _controller,
                            expands: true,
                            paintCursorAboveText: true,
                            placeholder: 'Once upon a time...',
                            scrollable: true,
                            autoFocus: true,
                            padding: const EdgeInsets.fromLTRB(
                                24.0, 20.0, 24.0, 24.0),
                            onImagePaste: (bytes) => Future.value(null),
                            onLaunchUrl: null,
                            embedBuilders: [CursorEmbedBuilder()],
                            showCursor: true,
                          ),
                          focusNode: focus,
                          scrollController: _scrollController,
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