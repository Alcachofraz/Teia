import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/comment_message.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/comment.dart' as c;
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/screens/chapter_editor/widgets/chat_gpt_view.dart';
import 'package:teia/screens/chapter_editor/widgets/comments/comment_card.dart';
import 'package:teia/screens/chapter_editor/widgets/comments/new_comment_card.dart';
import 'package:teia/screens/chapter_editor/widgets/cursor/cursor_embed_builder.dart';
import 'package:teia/screens/chapter_editor/widgets/snippets/snippet_choice_card.dart';
import 'package:teia/screens/chapter_editor/widgets/snippets/snippet_image_card.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/services/storage_service.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/tap_icon.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:universal_html/html.dart';
import 'package:file_picker/file_picker.dart';

class PageEditor extends StatefulWidget {
  final int pageId;
  final Group group;
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
    required this.group,
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
  late StreamSubscription _onContextMenu;
  late StreamSubscription _commentsChangesSubscription;
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
  bool showingNewComment = false;
  late int _sessionStartTimestamp;

  Color accentColor = ArtService.value.pastel();

  final StorageService storageService = Get.put(StorageService());

  bool pasting = false;

  List<c.Comment> comments = [];

  @override
  void initState() {
    page = tPage.empty(
      widget.pageId,
      widget.chapter.id,
      widget.chapter.storyId,
    );
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

    _pageChangesSubscription = ChapterManagementService.value
        .streamPageChanges(
          widget.chapter.storyId,
          widget.chapter.id.toString(),
          widget.pageId.toString(),
        )
        .listen(_onRemoteChange);

    // Stream comments
    _commentsChangesSubscription = ChapterManagementService.value
        .streamCommentsChanges(
      widget.chapter.storyId,
      widget.chapter.id.toString(),
      widget.pageId.toString(),
    )
        .listen((data) {
      setState(() {
        comments = data;
      });
    });

    /*_pageSubscription = ChapterManagementService.value
        .pageStream(
          widget.chapter.storyId,
          widget.chapter.id.toString(),
          widget.pageId.toString(),
        )
        .listen(_onPageChange);*/

    super.initState();
  }

  @override
  void dispose() {
    _pageChangesSubscription.cancel();
    _localChangesSubscription.cancel();
    //_pageSubscription.cancel();
    _controller.dispose();
    _onContextMenu.cancel();
    _scrollController.dispose();
    _commentsChangesSubscription.cancel();
    ChapterManagementService.value.simplifyChangesQueue(page);
    super.dispose();
  }

  /// Push the chapter object to Firestore.
  Future<void> _pushChapterToRemote(Chapter chapter) async {
    //Logs.d('Sending:\n${chapter.toString()}');
    if (widget.pushChapterToRemote != null) {
      await widget.pushChapterToRemote!(widget.chapter);
    }
  }

  /// Push the page object to Firestore.
  Future<void> _pushPageToRemote(tPage? page) async {
    //Logs.d('Sending:\n${page?.getRawText()}');
    if (widget.pushPageToRemote != null && page != null) {
      await widget.pushPageToRemote!(page);
    }
  }

  /// Push page delta changes to Firebase Realtime.
  void _pushPageChange(Change change) {
    ChapterManagementService.value.pushPageChange(
      widget.chapter.storyId,
      widget.chapter.id.toString(),
      widget.pageId.toString(),
      change,
      cursorPosition: _controller.selection.end,
    );
    _pushPageToRemote(page);
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

  /// Update page object with new page.
  void _onPageChange(tPage newPage) {
    page.updateWith(newPage);
  }

  /// When a remote change is received.
  void _onRemoteChange(Change change) {
    try {
      if (change.uid == AuthenticationService.value.uid &&
          change.timestamp > _sessionStartTimestamp &&
          change.type != ChangeType.format &&
          change.requeue) {
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
    } catch (e) {
      print('Error parsing remote change: $e');
      throw Exception('Error parsing remote change: $e');
    }
  }

  /// On document insert.
  void _onLocalInsert(LetterId? id, String text) {
    //print('INSERT [$id, $text]');
    if (text.length > 1) {
      setState(() {
        pasting = true;
      });
    }
    page.insert(id, text);
    _pushPageChange(
      Change(
        id,
        ChangeType.insert,
        AuthenticationService.value.uid ?? '-1',
        DateTime.now().millisecondsSinceEpoch,
        letter: text,
      ),
    );
    if (text.length > 1) {
      setState(() {
        pasting = false;
      });
    }
  }

  /// On document delete.
  void _onLocalDelete(LetterId? id, int length) {
    //print('DELETE [$id, $length]');
    page.delete(id, length);
    _pushPageChange(
      Change(
        id,
        ChangeType.delete,
        AuthenticationService.value.uid ?? '-1',
        DateTime.now().millisecondsSinceEpoch,
        length: length,
      ),
    );
    _checkLinksOnDelete();
  }

  /// On document format
  void _onLocalFormat(LetterId? id, int length, Snippet snippet) {
    //print('FORMAT [$id, $length, $snippet]');
    page.format(id, length, snippet);
    _pushPageChange(
      Change(
        id,
        ChangeType.format,
        AuthenticationService.value.uid ?? '-1',
        DateTime.now().millisecondsSinceEpoch,
        length: length,
        snippet: snippet,
      ),
    );
  }

  /// On create comment -> add coment to backend
  Future<void> _onCommentCreate(String text) async {
    await ChapterManagementService.value.createComment(
      c.Comment(
        messages: [
          CommentMessage(
            username:
                widget.group.userState[AuthenticationService.value.uid]!.name,
            message: text,
            avatar:
                widget.group.userState[AuthenticationService.value.uid]!.avatar,
            uid: widget.group.userState[AuthenticationService.value.uid]!.uid,
          ),
        ],
        id: '-1',
        storyId: widget.chapter.storyId,
        chapterId: widget.chapter.id.toString(),
        pageId: widget.pageId.toString(),
      ),
    );
  }

  /// On respond to comment -> add coment message to backend
  Future<void> _onCommentRespond(c.Comment comment, String text) async {
    await ChapterManagementService.value.addCommentMessage(
      comment,
      text,
      widget.group.userState[AuthenticationService.value.uid]!.avatar,
      widget.group.userState[AuthenticationService.value.uid]!.name,
      widget.group.userState[AuthenticationService.value.uid]!.uid,
    );
  }

  /// On create comment -> remove coment from backend and de-format page
  Future<void> _onCommentResolve(c.Comment comment) async {
    await ChapterManagementService.value.removeComment(comment);
  }

  /// Check if there are any links that need deleting, after local delete.
  Future<void> _checkLinksOnDelete() async {
    Set<int> links = {};
    links.addAll(widget.chapter.links.nodes[widget.pageId] ?? []);
    Set<int> actualLinks = {};
    if (links.isEmpty) return;
    for (Letter letter in page.letters) {
      if (letter.snippet != null &&
          letter.snippet!.type == SnippetType.choice) {
        actualLinks.add(letter.snippet!.attributes['choice']);
      }
    }
    Set<int> diff = links.difference(actualLinks);
    for (int id in diff) {
      widget.chapter.removeLink(widget.pageId, id);
    }
    _pushChapterToRemote(widget.chapter);
  }

  /// When the user positions the cursor or selects text
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

  /// Create a snippet from the selected text [_selection]
  void _createSnippet(Snippet snippet) {
    // 1. and 3.
    _onLocalFormat(page.letters[_selection!.start].id,
        (_selection!.end - _selection!.start).abs(), snippet);
    // 2.
    _controller.formatSelection(
      ColorAttribute(
        '#${colorToHex(Colors.blue)}', // Set color to blue - snippet
      ),
    );
  }

  /// Uploads image to Firebase Storage and creates a snippet with the image URL.
  Future<void> _onAddImage(String image) async {
    _createSnippet(Snippet(
      _selection!.textInside(_controller.document.toPlainText()),
      SnippetType.image,
      {
        'url': image,
      },
    ));
  }

  /// When the user adds a choice snippet to the text [_selection]
  /// Adds a page to the chapter object, if it doesn't exist.
  /// Creates the link from the current page to the new one, and creates the snippet.
  ///
  void _onAddChoice([int? id]) async {
    if (_selection == null) return;
    // If id is null, create a new page and get its id
    if (id == null) {
      id = widget.chapter.addPage(page.id);
      ChapterManagementService.value.pageCreate(
        tPage.empty(
          id,
          int.parse(widget.chapter.id.toString()),
          widget.chapter.storyId,
        ),
        widget.chapter.graph,
      );
    }

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

  // Get String content from each of the pages before
  // the current page in this chapter
  Future<List<String>> getChapterContent() async {
    List<String> pages = [];
    int i = page.id;
    String content =
        _controller.document.getPlainText(0, _controller.document.length);
    if (content.isNotEmpty && content != '\n') {
      pages.add(content);
    }
    bool secondToLastPage = true;
    while (i > 1) {
      i = widget.chapter.graph.nodes.entries
          .firstWhere(
              (MapEntry<int, Set<int>> entry) => entry.value.contains(i))
          .key;

      List<String> content =
          await ChapterManagementService.value.getPageContent(
        widget.chapter.storyId,
        widget.chapter.id.toString(),
        i.toString(),
        nextPageId: secondToLastPage ? widget.pageId.toString() : null,
      );
      if (secondToLastPage && content[0].isNotEmpty && content[0] != '\n') {
        pages.add(content[0]);
        secondToLastPage = false;
      }
      if (content[1].isNotEmpty && content[1] != '\n') {
        pages.add(content[1]);
      }
    }
    return pages.reversed.toList();
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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (_atSnippet != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _snippetCard(_atSnippet!),
            ),
          if (showingNewComment)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: NewCommentCard(
                onComplete: (String text) {
                  _onCommentCreate(text);
                  setState(() {
                    showingNewComment = false;
                  });
                },
                onDismiss: () {
                  setState(() {
                    showingNewComment = false;
                  });
                },
              ),
            )
          else
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Tile(
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                  radiusAll: 4.0,
                  child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 20),
                          Gap(8),
                          Text('New comment'),
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showingNewComment = true;
                      });
                    },
                  ),
                ),
              ),
            ),
          for (c.Comment comment in comments)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CommentCard(
                comment: comment,
                onRespond: _onCommentRespond,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: ChatGPTView(
              getChapterContent: getChapterContent,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pasting() {
    return pasting
        ? const Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Tile(
              padding: EdgeInsets.zero,
              radiusAll: 64,
              elevation: 8,
              width: Utils.textOptionsWidth,
              color: Colors.white,
              child: Row(
                children: [
                  Text('Pasting... '),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
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
                                  for (int id in widget
                                      .chapter.graph.nodes[widget.pageId]!)
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
                                          '/image_generate',
                                          parameters: {
                                            'text': _selection?.textInside(
                                                  _controller.document
                                                      .toPlainText(),
                                                ) ??
                                                '',
                                            'story_id': widget.chapter.storyId,
                                            'chapter_id':
                                                widget.chapter.id.toString(),
                                          });
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
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform
                                              .pickFiles(type: FileType.image);
                                      if (result != null) {
                                        String url =
                                            await storageService.uploadImage(
                                          widget.chapter.storyId,
                                          widget.chapter.id.toString(),
                                          result.files.single.bytes!,
                                        );
                                        _onAddImage(url);
                                      }
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
                    /*JustTheTooltip(
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
                            showingNewComment = true;
                          });
                        },
                      ),
                    ),*/
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
    int pageId = widget.pageId;
    for (int id in widget.chapter.graph.nodes[pageId]!) {
      if (!widget.chapter.links.nodes[pageId]!.contains(id)) {
        missingLinks.add(id);
      }
    }

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          controller: _controller,
                          configurations: QuillEditorConfigurations(
                            expands: true,
                            paintCursorAboveText: true,
                            placeholder: 'Once upon a time...',
                            scrollable: true,
                            autoFocus: true,
                            padding: const EdgeInsets.fromLTRB(
                              24.0,
                              20.0,
                              24.0,
                              24.0,
                            ),
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
        _pasting(),
      ],
    );
  }
}
