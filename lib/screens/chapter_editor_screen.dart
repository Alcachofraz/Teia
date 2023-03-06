import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/chapter.dart';
import 'package:teia/screens/chapter_graph.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/views/text_editor/page_editor.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:multi_split_view/multi_split_view.dart';

class ChapterEditorScreen extends StatefulWidget {
  final bool picking;

  const ChapterEditorScreen({Key? key, this.picking = false}) : super(key: key);

  @override
  State<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  final Chapter _chapter = Chapter.create(1, 'storyId', 'My chapter', AuthenticationService.uid);
  late double textEditorWeight;
  int? selectedPageId;

  final MultiSplitViewController _multiSplitViewController = MultiSplitViewController(
    areas: [
      Area(minimalWeight: 1 - Utils.textEditorMaximumWeight, weight: 1 - Utils.textEditorDefaultWeight),
      Area(minimalWeight: Utils.textEditorMinimumWeight, weight: Utils.textEditorDefaultWeight),
    ],
  );

  @override
  void initState() {
    textEditorWeight = Utils.textEditorDefaultWeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      backgroundColor: Utils.graphSettings.backgroundColor,
      body: Stack(
        children: [
          ChapterGraph(
            chapter: _chapter,
            createPage: (pageId) {
              setState(() {
                _chapter.addPage(pageId, AuthenticationService.uid);
              });
            },
            clickPage: (pageId) {
              if (selectedPageId != null) {
                if (selectedPageId == pageId) {
                  return;
                }
                setState(() {
                  selectedPageId = null;
                });
                Future.delayed(
                  const Duration(milliseconds: Utils.textEditorAnimationDuration),
                  () {
                    setState(() {
                      selectedPageId = pageId;
                    });
                  },
                );
              } else {
                setState(() {
                  selectedPageId = pageId;
                });
              }
            },
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: Utils.textEditorAnimationDuration),
            curve: Curves.decelerate,
            right: selectedPageId == null ? -(MediaQuery.of(context).size.width * textEditorWeight) : 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: MultiSplitView(
                controller: _multiSplitViewController,
                onWeightChange: () {
                  setState(() {
                    textEditorWeight = _multiSplitViewController.areas[1].weight!;
                  });
                },
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
        ],
      ),
    );
  }
}
