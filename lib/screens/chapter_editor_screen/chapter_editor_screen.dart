import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/chapter.dart';
import 'package:teia/models/editing_page.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/screens/chapter_editor_screen/chapter_graph_view.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/screens/chapter_editor_screen/widgets/page_editor.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/scrollable_static_scaffold.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:sorted_list/sorted_list.dart';

class ChapterEditorScreen extends StatefulWidget {
  final bool picking;
  final String chapterId;
  final String storyId;

  const ChapterEditorScreen({
    Key? key,
    required this.storyId,
    required this.chapterId,
    this.picking = false,
  }) : super(key: key);

  @override
  State<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  Chapter? _chapter;
  late double textEditorWeight;
  late double loosePagesMenuHeight;
  late StreamSubscription _chapterSubscription;
  int? selectedPageId;
  bool showingLoosePages = false;
  final FocusNode pageEditorFocusNode = FocusNode();

  final MultiSplitViewController _loosePagesMultiSplitViewController = MultiSplitViewController(
    areas: [
      Area(minimalWeight: 1 - Utils.loosePagesMenuMaximumHeight, weight: 1 - Utils.loosePagesMenuDefaultHeight),
      Area(minimalWeight: Utils.loosePagesMenuMinimumHeight, weight: Utils.loosePagesMenuDefaultHeight),
    ],
  );

  @override
  void initState() {
    textEditorWeight = Utils.editorWeight;
    loosePagesMenuHeight = Utils.loosePagesMenuDefaultHeight;
    _chapterSubscription = ChapterManagementService.chapterStream(widget.storyId, widget.chapterId).listen((chapter) => setState(() => _chapter = chapter));
    super.initState();
  }

  @override
  void dispose() {
    _chapterSubscription.cancel();
    super.dispose();
  }

  Future<void> _pushChapterToRemote(Chapter chapter) async {
    await ChapterManagementService.chapterSet(chapter);
  }

  Future<void> _pushPageToRemote(EditingPage page) async {
    await ChapterManagementService.pageSet(page, AuthenticationService.uid);
  }

  void _clickPage(pageId) {
    if (selectedPageId != null) {
      // If a page is already selected
      if (selectedPageId == pageId) {
        // If selected the same page, do nothing.
        return;
      }
      // Deselect page
      setState(() {
        selectedPageId = null;
      });
      // After animation, select new page
      Future.delayed(
        const Duration(milliseconds: Utils.textEditorAnimationDuration),
        () {
          setState(() {
            selectedPageId = pageId;
          });
        },
      );
    } else {
      // If no page is currently selected
      setState(() {
        selectedPageId = pageId;
      });
    }
  }

  void _createPage(pageId) {
    int newId = _chapter!.addPage(pageId, uid: AuthenticationService.uid);
    // Update local
    setState(() {});
    ChapterManagementService.pageCreate(
      EditingPage(
        newId,
        int.parse(widget.chapterId),
        widget.storyId,
        SortedList<Letter>(),
        [],
        null,
      ),
      _chapter!.graph,
    );
  }

  Widget _dividerBuilder(bool vertical, axis, index, resizable, dragging, highlighted, themeData) => resizable
      ? Container(
          color: dragging ? Colors.grey[300] : Colors.grey[100],
          child: RotatedBox(
            quarterTurns: vertical ? 0 : 1,
            child: Icon(
              Icons.drag_indicator,
              size: Utils.dividerThickness,
              color: highlighted ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        )
      : const SizedBox.shrink();

  Widget _chapterGraph(Size size) => _chapter == null
      ? loadingRotate()
      : ChapterGraphView(
          chapter: _chapter!,
          createPage: _createPage,
          clickPage: _clickPage,
          width: size.width,
          height: size.height,
        );

  Widget _pageEditor(Size size) => _chapter == null
      ? loadingRotate()
      : Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: Utils.textEditorAnimationDuration),
              curve: Curves.decelerate,
              right: selectedPageId == null ? -size.width * (size.width > Utils.maxWidthShowOnlyEditor ? textEditorWeight : 1.0) : 0,
              child: SizedBox(
                width: size.width * (size.width > Utils.maxWidthShowOnlyEditor ? textEditorWeight : 1.0),
                height: size.height,
                child: Container(
                  color: Utils.pageEditorBackgroundColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Tile(
                        padding: EdgeInsets.zero,
                        elevation: 0.0,
                        color: Utils.pageEditorBackgroundColor,
                        child: const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: Utils.collapseButtonSize,
                        ),
                        onTap: () {
                          setState(() {
                            selectedPageId = null;
                          });
                        },
                      ),
                      selectedPageId != null
                          ? Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8.0, 18.0, 16.0, 0.0),
                                    child: Text(
                                      'Page ${selectedPageId!}',
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
                                    child: PageEditor(
                                      pageId: selectedPageId!.toString(),
                                      focusNode: pageEditorFocusNode,
                                      pushPageToRemote: _pushPageToRemote,
                                      pushChapterToRemote: _pushChapterToRemote,
                                      screenSize: size,
                                      chapter: _chapter!,
                                      onPageTap: (pageId) => _clickPage(pageId),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ScrollableStaticScaffold(
      backgroundColor: Utils.graphSettings.backgroundColor,
      body: Stack(
        children: [
          _chapterGraph(screenSize),
          _pageEditor(screenSize),
        ],
      ),
    );
  }
}
