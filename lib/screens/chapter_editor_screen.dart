import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/chapter.dart';
import 'package:teia/models/chapter_graph.dart';
import 'package:teia/models/page.dart';
import 'package:teia/screens/chapter_graph_view.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_edit_service.dart';
import 'package:teia/views/text_editor/page_editor.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:multi_split_view/multi_split_view.dart';

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
  Chapter _chapter = Chapter.create(1, 'storyId', 'My chapter', AuthenticationService.uid);
  late double textEditorWeight;
  late double loosePagesMenuHeight;
  late StreamSubscription _chapterSubscription;
  int? selectedPageId;
  bool showingLoosePages = false;
  final FocusNode pageEditorFocusNode = FocusNode();

  final MultiSplitViewController _textEditorMultiSplitViewController = MultiSplitViewController(
    areas: [
      Area(minimalWeight: 1 - Utils.textEditorMaximumWeight, weight: 1 - Utils.textEditorDefaultWeight),
      Area(minimalWeight: Utils.textEditorMinimumWeight, weight: Utils.textEditorDefaultWeight),
    ],
  );

  final MultiSplitViewController _loosePagesMultiSplitViewController = MultiSplitViewController(
    areas: [
      Area(minimalWeight: 1 - Utils.loosePagesMenuMaximumHeight, weight: 1 - Utils.loosePagesMenuDefaultHeight),
      Area(minimalWeight: Utils.loosePagesMenuMinimumHeight, weight: Utils.loosePagesMenuDefaultHeight),
    ],
  );

  @override
  void initState() {
    textEditorWeight = Utils.textEditorDefaultWeight;
    loosePagesMenuHeight = Utils.loosePagesMenuDefaultHeight;
    _chapterSubscription = ChapterEditService.chapterStream(widget.storyId, widget.chapterId)
        .listen((chapter) => setState(() => _chapter = chapter));
    super.initState();
  }

  void pushPageToRemote(Page page) {
    ChapterEditService.pageSet(page, AuthenticationService.uid);
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

  Widget _chapterGraph() => ChapterGraphView(
        chapter: _chapter,
        createPage: (pageId) {
          ChapterGraph graph = _chapter.addPage(pageId, uid: AuthenticationService.uid);
          // Update local
          setState(() {});
          ChapterEditService.pageCreate(
            Page(
              pageId,
              int.parse(widget.chapterId),
              widget.storyId,
              [],
              null,
            ),
            graph,
          );
        },
        clickPage: (pageId) {
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
        },
      );

  Widget _loosePages() => AnimatedPositioned(
        duration: const Duration(milliseconds: Utils.textEditorAnimationDuration),
        curve: Curves.decelerate,
        bottom: showingLoosePages ? 0 : -(MediaQuery.of(context).size.height * loosePagesMenuHeight) + 48.0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (1 - textEditorWeight),
          height: MediaQuery.of(context).size.height,
          child: MultiSplitViewTheme(
            data: MultiSplitViewThemeData(dividerThickness: Utils.dividerThickness),
            child: MultiSplitView(
              axis: Axis.vertical,
              resizable: showingLoosePages,
              onWeightChange: () {
                setState(() {
                  loosePagesMenuHeight = _loosePagesMultiSplitViewController.areas[1].weight!;
                });
              },
              dividerBuilder: (axis, index, resizable, dragging, highlighted, themeData) =>
                  _dividerBuilder(false, axis, index, resizable, dragging, highlighted, themeData),
              controller: _loosePagesMultiSplitViewController,
              children: [
                const SizedBox.shrink(),
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Tile(
                        padding: EdgeInsets.zero,
                        elevation: 0.0,
                        onTap: () => setState(() {
                          showingLoosePages = !showingLoosePages;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Icon(showingLoosePages ? Icons.chevron_right : Icons.chevron_left),
                                ),
                              ),
                              const Expanded(
                                  child: Text(
                                'All pages',
                                textAlign: TextAlign.left,
                              )),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: const [],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _pageEditor() => AnimatedPositioned(
        duration: const Duration(milliseconds: Utils.textEditorAnimationDuration),
        curve: Curves.decelerate,
        right: selectedPageId == null ? -(MediaQuery.of(context).size.width * textEditorWeight) : 0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: MultiSplitViewTheme(
            data: MultiSplitViewThemeData(dividerThickness: Utils.dividerThickness),
            child: MultiSplitView(
              controller: _textEditorMultiSplitViewController,
              onWeightChange: () {
                setState(() {
                  textEditorWeight = _textEditorMultiSplitViewController.areas[1].weight!;
                });
              },
              dividerBuilder: (axis, index, resizable, dragging, highlighted, themeData) =>
                  _dividerBuilder(true, axis, index, resizable, dragging, highlighted, themeData),
              children: [
                const SizedBox.shrink(),
                Container(
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Tile(
                        padding: EdgeInsets.zero,
                        elevation: 0.0,
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
                              child: PageEditor(
                                pageId: selectedPageId!.toString(),
                                focusNode: pageEditorFocusNode,
                                pushPageToRemote: pushPageToRemote,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      backgroundColor: Utils.graphSettings.backgroundColor,
      body: Stack(
        children: [
          _chapterGraph(),
          _loosePages(),
          _pageEditor(),
        ],
      ),
    );
  }
}
