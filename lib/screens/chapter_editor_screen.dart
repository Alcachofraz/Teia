import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/chapter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/screens/chapter_graph.dart';
import 'package:teia/screens/text_editor.dart';
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
  final Chapter _chapter = Chapter.create(1, 'My chapter');
  late double textEditorWeight;
  Page? selectedPage;

  late MultiSplitViewController _multiSplitViewController;

  @override
  void initState() {
    textEditorWeight = Utils.textEditorWeight;
    _multiSplitViewController = MultiSplitViewController(
      areas: [
        Area(minimalWeight: 0.25, weight: 1 - Utils.textEditorWeight),
        Area(minimalWeight: 0.25, weight: Utils.textEditorWeight),
      ],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      backgroundColor: Utils.backgroundColor,
      body: Stack(
        children: [
          ChapterGraph(
            chapter: _chapter,
            createPage: (pageId) {
              setState(() {
                _chapter.addPage(pageId);
              });
            },
            clickPage: (pageId) {
              if (selectedPage != null) {
                if (selectedPage!.id == pageId) {
                  return;
                }
                // Animate off and on!
                setState(() {
                  selectedPage = null;
                });
                Future.delayed(
                  const Duration(milliseconds: Utils.textEditorAnimationDuration),
                  () {
                    setState(() {
                      selectedPage = _chapter.pages[pageId - 1];
                    });
                  },
                );
              } else {
                setState(() {
                  selectedPage = _chapter.pages[pageId - 1];
                });
              }
            },
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: Utils.textEditorAnimationDuration),
            curve: Curves.decelerate,
            right: selectedPage == null ? -(MediaQuery.of(context).size.width * textEditorWeight) : 0,
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
                          child: const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: Utils.collapseButtonSize,
                          ),
                          onTap: () {
                            setState(() {
                              selectedPage = null;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8.0, 18.0, 16.0, 0.0),
                                child: Text(
                                  'Page ${selectedPage?.id ?? 1}',
                                  style: TextStyle(
                                    color: Utils.nodeBorderColor,
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
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                                  child: selectedPage != null
                                      ? TextEditor(page: selectedPage!)
                                      : const Center(
                                          child: Text('Nothing to be seen here.'),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
