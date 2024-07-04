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
import 'package:teia/screens/chapter_editor/popups/delete_page_popup.dart';
import 'package:teia/screens/chapter_editor/widgets/page_editor.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/services/group_management_service.dart';
import 'package:teia/utils/loading.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
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
  final RxBool allowed = false.obs;
  late Color buttonColor;
  final String landscape = ArtService.value.landscape();
  RxBool loading = false.obs;

  Set<int> missingLinks = {};

  @override
  void initState() {
    loading.value = true;
    textEditorWeight = Utils.editorWeight;
    loosePagesMenuHeight = Utils.loosePagesMenuDefaultHeight;
    _chapterSubscription = chapterManagementService
        .chapterStream(widget.storyId, widget.chapterId)
        .listen(
      (chapter) {
        setState(() => _chapter = chapter);
      },
    );
    _groupSubscription =
        GroupManagementService.value.groupStream(widget.group).listen(
      (group) {
        allowed.value = group.users.contains(
              AuthenticationService.value.uid,
            ) &&
            group.userState[AuthenticationService.value.uid]!.role ==
                Role.writer;
        if (allowed.value) {
          if (group.state != (_group?.state ?? group.state)) {
            Get.back();
          }
          setState(() => _group = group);
        }
        loading.value = false;
      },
    );
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
      tPage.empty(
        newId,
        int.parse(widget.chapterId),
        widget.storyId,
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
          missingLinks: missingLinks,
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
                                    child: Row(
                                      children: [
                                        Text(
                                          'Page ${selectedPageId!}',
                                          style: TextStyle(
                                            color: Utils
                                                .graphSettings.nodeBorderColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        const Gap(8),
                                        if (missingLinks
                                            .contains(selectedPageId))
                                          const Icon(
                                            Icons.link_off_rounded,
                                            color: Colors.red,
                                            size: 18.0,
                                          ),
                                        const Gap(4),
                                        const Spacer(),
                                        const Gap(4),
                                        IconButton(
                                          onPressed: () {
                                            int pageId = selectedPageId!;
                                            if (_chapter!
                                                .canPageBeDeleted(pageId)) {
                                              setState(() {
                                                selectedPageId = null;
                                              });
                                              _chapter!.deletePage(pageId);
                                              _pushChapterToRemote(_chapter!);
                                              ChapterManagementService.value
                                                  .pageDelete(
                                                _chapter!.storyId,
                                                _chapter!.id,
                                                pageId,
                                              );
                                            } else {
                                              openDeletePopupError(
                                                context,
                                                pageId,
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
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

    missingLinks.clear();
    if (_chapter != null) {
      for (int id in _chapter!.graph.nodes.keys) {
        for (int link in _chapter!.graph.nodes[id] ?? []) {
          if (_chapter!.links.nodes[id] == null ||
              !_chapter!.links.nodes[id]!.contains(link)) {
            missingLinks.add(id);
          }
        }
      }
    }
    return Obx(
      () => loading.value
          ? const ScreenWrapper(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : allowed.value
              ? ScrollableStaticScaffold(
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
                        color: Colors.white.withOpacity(0.85),
                        width: screenSize.width,
                        height: screenSize.height,
                      ),
                      _chapterGraph(screenSize),
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
                                Text(
                                  _chapter?.title ?? '...',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      _pageEditor(screenSize),
                    ],
                  ),
                )
              : ScreenWrapper(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'You don\'t have permission to see this page.',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const Gap(20),
                        SizedBox(
                          width: 300,
                          child: TeiaButton(
                            text: 'Go Back',
                            onTap: () => Get.back(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
