import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/screens/chapter_editor/chapter_graph_view.dart';
import 'package:teia/screens/chapter_editor/widgets/page_editor.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/services/group_management_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/scrollable_static_scaffold.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:teia/views/teia_button.dart';

class ChapterEditorScreen extends StatefulWidget {
  final bool picking;
  final String chapterId = Get.parameters['chapterId']!;
  final String storyId = Get.parameters['storyId']!;
  final String group = Get.parameters['group']!;

  ChapterEditorScreen({
    super.key,
    this.picking = false,
  });

  @override
  State<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  Chapter? _chapter;
  Group? _group;
  late double textEditorWeight;
  late double loosePagesMenuHeight;
  late StreamSubscription _chapterSubscription;
  late StreamSubscription _groupSubscription;
  int? selectedPageId;
  bool showingLoosePages = false;
  final FocusNode pageEditorFocusNode = FocusNode();
  final ChapterManagementService chapterManagementService =
      Get.put(ChapterManagementService());
  late Color buttonColor;
  final String landscape = ArtService.value.landscape();

  @override
  void initState() {
    textEditorWeight = Utils.editorWeight;
    loosePagesMenuHeight = Utils.loosePagesMenuDefaultHeight;
    _chapterSubscription = chapterManagementService
        .chapterStream(widget.storyId, widget.chapterId)
        .listen((chapter) => setState(() => _chapter = chapter));
    _groupSubscription = GroupManagementService.value
        .groupStream(widget.group)
        .listen((group) => setState(() => _group = group));
    buttonColor = ArtService.value.pastel();
    super.initState();
  }

  @override
  void dispose() {
    _chapterSubscription.cancel();
    _groupSubscription.cancel();
    super.dispose();
  }

  Future<void> _pushChapterToRemote(Chapter chapter) async {
    await chapterManagementService.chapterSet(chapter);
  }

  Future<void> _pushPageToRemote(tPage page) async {
    await chapterManagementService.pageSet(
        page, AuthenticationService.value.uid);
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
    int newId = _chapter!.addPage(pageId, uid: AuthenticationService.value.uid);
    // Update local
    setState(() {});
    chapterManagementService.pageCreate(
      tPage(
        newId,
        int.parse(widget.chapterId),
        widget.storyId,
        SortedList<Letter>(),
        null,
        {},
      ),
      _chapter!.graph,
    );
  }

  Widget _dividerBuilder(bool vertical, axis, index, resizable, dragging,
          highlighted, themeData) =>
      resizable
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
              duration: const Duration(
                  milliseconds: Utils.textEditorAnimationDuration),
              curve: Curves.decelerate,
              right: selectedPageId == null
                  ? -size.width *
                      (size.width > Utils.maxWidthShowOnlyEditor
                          ? textEditorWeight
                          : 1.0)
                  : 0,
              child: SizedBox(
                width: size.width *
                    (size.width > Utils.maxWidthShowOnlyEditor
                        ? textEditorWeight
                        : 1.0),
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
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 18.0, 16.0, 0.0),
                                    child: Text(
                                      'Page ${selectedPageId!}',
                                      style: TextStyle(
                                        color:
                                            Utils.graphSettings.nodeBorderColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                                    child: Divider(),
                                  ),
                                  Expanded(
                                    child: PageEditor(
                                      pageId: selectedPageId!,
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
          Image.asset(
            landscape,
            fit: BoxFit.cover,
            width: screenSize.width,
            height: screenSize.height,
          ),
          Container(
            color: Colors.grey.withOpacity(0.9),
            width: screenSize.width,
            height: screenSize.height,
          ),
          _chapterGraph(screenSize),
          _pageEditor(screenSize),
          if (_group != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter ${_chapter?.id ?? '...'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _chapter?.title ?? '...',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
