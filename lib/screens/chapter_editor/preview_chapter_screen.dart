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

class PreviewChapterScreen extends StatefulWidget {
  final String chapterId = Get.parameters['chapterId']!;
  final String storyId = Get.parameters['storyId']!;
  final String group = Get.parameters['group']!;

  PreviewChapterScreen({
    super.key,
  });

  @override
  State<PreviewChapterScreen> createState() => _PreviewChapterScreenState();
}

class _PreviewChapterScreenState extends State<PreviewChapterScreen> {
  final Rxn<tPage?> _page = Rxn<tPage>();
  final Rxn<Chapter?> _chapter = Rxn<Chapter>();
  final Rxn<Group?> _group = Rxn<Group>();

  final RxBool allowed = false.obs;
  RxBool loading = false.obs;
  RxBool loadingPage = false.obs;
  RxList<int> path = <int>[].obs;

  late StreamSubscription _groupSubscription;
  final String landscape = ArtService.value.landscape();
  final Color color = ArtService.value.pastel();

  @override
  void initState() {
    loading.value = true;

    GroupManagementService.value.groupGet(widget.group).then(
      (group) {
        if (group != null) {
          allowed.value = group.users.contains(
                AuthenticationService.value.uid,
              ) &&
              group.userState[AuthenticationService.value.uid]!.role ==
                  Role.writer;
          if (allowed.value) {
            path.add(1);
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
    _page.value = await ChapterManagementService.value.pageGet(
      widget.storyId,
      widget.chapterId,
      choice.toString(),
    );
    path.add(choice);
    await Future.delayed(500.milliseconds);
    loadingPage.value = false;
  }

  void onBack() {
    loadingPage.value = true;
    // Remove current
    path.removeLast();
    // Get previous and remove it
    final last = path.removeLast();
    // Navigate to it again
    onChoice(last);
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
    Get.back();
  }

  List<TextSpan> _getSpans(tPage? page) {
    if (page == null) return [];
    return page.snippets
        .map(
          (s) => TextSpan(
            text: s.text,
            style: !_chapter.value!.showHighlights
                ? Utils.textReadingStyle
                : (s.type == SnippetType.text
                    ? Utils.textReadingStyle
                    : (s.type == SnippetType.choice
                        ? Utils.textReadingStyle.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          )
                        : Utils.textReadingStyle.copyWith(
                            color: color,
                            decoration: TextDecoration.underline,
                          ))),
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

  Widget _header() => Column(
        children: [
          SizedBox(height: 16),
          Obx(
            () => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chapter ${_chapter.value?.id.toString() ?? '...'}',
                style: TextStyle(
                  fontSize: 13.0,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Page ${path.isEmpty ? '1' : path.last}',
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
            padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
            child: Divider(),
          ),
        ],
      );

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
                      Obx(
                        () => loadingPage.value
                            ? Material(
                                color: Utils.pageEditorBackgroundColor,
                                elevation: 4,
                                child: SizedBox(
                                  width: 800,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      _header(),
                                      Expanded(
                                        child: Center(
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: CircularProgressIndicator(
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Material(
                                color: Utils.pageEditorBackgroundColor,
                                elevation: 4,
                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    width: 800,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 16, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          _header(),
                                          Gap(24),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    style:
                                                        Utils.textReadingStyle,
                                                    children:
                                                        _getSpans(_page.value),
                                                  ),
                                                ),
                                                if (_page.value?.isLeaf(
                                                        reading: true) ??
                                                    false)
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 16,
                                                      ),
                                                      child: TextButton(
                                                        onPressed: _finish,
                                                        child: const Text(
                                                          '🏁 Finish Chapter',
                                                          style: TextStyle(
                                                            color: Colors.blue,
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
                                          Gap(64),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Obx(
                        () => path.length > 1
                            ? Positioned(
                                top: 16,
                                left: 16,
                                child: Material(
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    onPressed: onBack,
                                    icon: Icon(
                                      Icons.reply_outlined,
                                      color: color,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
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
