import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/services/group_management_service.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:teia/views/teia_button.dart';
import 'package:photo_view/photo_view.dart';

class ReadChapterScreen extends StatefulWidget {
  final String chapterId = Get.parameters['chapterId']!;
  final String storyId = Get.parameters['storyId']!;
  final String group = Get.parameters['group']!;

  ReadChapterScreen({
    super.key,
  });

  @override
  State<ReadChapterScreen> createState() => _ReadChapterScreenState();
}

class _ReadChapterScreenState extends State<ReadChapterScreen> {
  final Rxn<tPage?> _page = Rxn<tPage>();
  final Rxn<Chapter?> _chapter = Rxn<Chapter>();
  final Rxn<Group?> _group = Rxn<Group>();

  final RxBool allowed = false.obs;
  RxBool loading = false.obs;
  RxBool loadingPage = false.obs;
  RxInt currentPage = 1.obs;

  late StreamSubscription _groupSubscription;
  final String landscape = ArtService.value.landscape();
  final Color color = ArtService.value.pastel();

  @override
  void initState() {
    loading.value = true;
    _groupSubscription =
        GroupManagementService.value.groupStream(widget.group).listen(
      (group) {
        allowed.value = group.users.contains(
              AuthenticationService.value.uid,
            ) &&
            group.userState[AuthenticationService.value.uid]!.role ==
                Role.reader;
        if (allowed.value) {
          if (group.state != (_group.value?.state ?? group.state)) {
            Get.back();
          }
          currentPage.value =
              group.userState[AuthenticationService.value.uid]!.currentPage;
          ChapterManagementService.value
              .pageGet(
            widget.storyId,
            widget.chapterId,
            group.userState[AuthenticationService.value.uid]!.currentPage
                .toString(),
          )
              .then((page) {
            _page.value = page;
          });
          setState(() => _group.value = group);
        }
        loading.value = false;
      },
    );
    ChapterManagementService.value
        .chapterGet(widget.storyId, widget.chapterId)
        .then((chapter) => _chapter.value = chapter);

    super.initState();
  }

  @override
  void dispose() {
    _groupSubscription.cancel();
    super.dispose();
  }

  /// Callback to when a choice is clicked.
  Future<void> onChoice(int choice) async {
    loadingPage.value = true;
    GroupManagementService.value.setReaderCurrentPage(
      _group.value!,
      choice,
    );
    _page.value = await ChapterManagementService.value.pageGet(
      widget.storyId,
      widget.chapterId,
      choice.toString(),
    );
    currentPage.value == choice;
    await Future.delayed(500.milliseconds);
    loadingPage.value = false;
  }

  /// Callback to when an image is clicked.
  void onImage(String url) {
    Get.dialog(
      Padding(
        padding: const EdgeInsets.all(64),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(url),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: Get.back,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Callback to when the chapter is finished.
  void _finish() {
    if (_group.value != null) {
      GroupManagementService.value.setReaderReady(
        _group.value!,
      );
    }
  }

  List<TextSpan> _getSpans(tPage? page) {
    if (page == null) return [];
    return page.snippets
        .map(
          (s) => TextSpan(
            text: s.text,
            recognizer:
                s.type == SnippetType.text ? null : TapGestureRecognizer()
                  ?..onTap = () {
                    if (s.type == SnippetType.choice) {
                      onChoice(s.attributes['choice']);
                    } else if (s.type == SnippetType.image) {
                      onImage(s.attributes['url']);
                    }
                  },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(
      () => loading.value
          ? const ScreenWrapper(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : allowed.value
              ? ScreenWrapper(
                  body: Stack(
                    alignment: Alignment.center,
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
                      Material(
                        color: Utils.pageEditorBackgroundColor,
                        elevation: 4,
                        child: SizedBox(
                          width: 800,
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SizedBox(
                                          height: screenSize.height * 0.03),
                                      Obx(
                                        () => Text(
                                          'Chapter ${_chapter.value?.id.toString() ?? '...'}',
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _chapter.value?.title ?? '...',
                                                style: const TextStyle(
                                                  fontSize: 28.0,
                                                ),
                                              ),
                                            ),
                                            Material(
                                              shape: const StadiumBorder(),
                                              color: color,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  'Page ${currentPage.value}',
                                                  style: const TextStyle(
                                                    fontSize: 11.0,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 8.0, 0.0, 8.0),
                                        child: Divider(),
                                      ),
                                      Expanded(
                                        child: Obx(
                                          () => Tile(
                                            width: double.infinity,
                                            elevation: 2.5,
                                            padding: EdgeInsets.zero,
                                            color: Utils.pageEditorSheetColor,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                24,
                                                28,
                                                24,
                                                24,
                                              ),
                                              child: loadingPage.value
                                                  ? Center(
                                                      child: SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: color,
                                                        ),
                                                      ),
                                                    )
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            style: Utils
                                                                .textReadingStyle,
                                                            children: _getSpans(
                                                                _page.value),
                                                          ),
                                                        ),
                                                        if (_page.value?.isLeaf(
                                                                reading:
                                                                    true) ??
                                                            false)
                                                          Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 16,
                                                              ),
                                                              child: TextButton(
                                                                onPressed:
                                                                    _finish,
                                                                child:
                                                                    const Text(
                                                                  '🏁 Finish Chapter',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
