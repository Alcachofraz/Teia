import 'package:flutter/material.dart' hide Page;
import 'package:teia/models/chapter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/screens/chapter_graph.dart';
import 'package:teia/screens/text_editor.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';

class ChapterEditorScreen extends StatefulWidget {
  final bool picking;

  const ChapterEditorScreen({Key? key, this.picking = false}) : super(key: key);

  @override
  State<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  final Chapter _chapter = Chapter.create(1, 'My chapter');
  Page? selectedPage;

  @override
  void initState() {
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
                  setState(() {
                    selectedPage = null;
                  });
                } else {
                  // Animate off and on!
                  setState(() {
                    selectedPage = null;
                  });
                  Future.delayed(
                    const Duration(milliseconds: 200),
                    () {
                      setState(() {
                        selectedPage = _chapter.pages[pageId - 1];
                      });
                    },
                  );
                }
              } else {
                setState(() {
                  selectedPage = _chapter.pages[pageId - 1];
                });
              }
            },
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            right: selectedPage == null ? -(MediaQuery.of(context).size.width / 3) : 0,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Tile(
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 32.0,
                    ),
                    onTap: () {
                      setState(() {
                        selectedPage = null;
                      });
                    },
                  ),
                  Expanded(
                    child: selectedPage != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8.0, 18.0, 16.0, 0.0),
                                child: Text(
                                  'Page ${selectedPage!.id}',
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
                                  child: TextEditor(page: selectedPage!),
                                ),
                              ),
                            ],
                          )
                        : Container(),
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
