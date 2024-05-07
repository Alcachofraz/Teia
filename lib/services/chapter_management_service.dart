import 'package:get/get.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/chapter_graph.dart';
import 'package:teia/models/note/note.dart';
import 'package:teia/models/page.dart';
import 'package:teia/services/firebase/firestore_utils.dart';
import 'package:teia/utils/logs.dart';

class ChapterManagementService extends GetxService {
  Stream<Chapter> chapterStream(
    String storyId,
    String chapterId,
  ) =>
      FirebaseUtils.firestore
          .collection('stories')
          .doc(storyId)
          .collection('chapters')
          .doc(chapterId)
          .snapshots()
          .asyncMap((doc) => Chapter.fromMap(doc.data()));

  Stream<tPage> pageStream(
    String storyId,
    String chapterId,
    String pageId,
  ) =>
      FirebaseUtils.firestore
          .collection('stories')
          .doc(storyId)
          .collection('chapters')
          .doc(chapterId)
          .collection('pages')
          .doc(pageId)
          .snapshots()
          .asyncMap((doc) => tPage.fromMap(doc.data()));

  Future<void> chapterSet(Chapter chapter) async {
    //Logs.d('Sending $page');
    try {
      FirebaseUtils.firestore
          .collection('stories')
          .doc(chapter.storyId)
          .collection('chapters')
          .doc(chapter.id.toString())
          .set(chapter.toMap());
    } catch (e) {
      Logs.d('Sending $chapter\n$e');
    }
  }

  Future<void> pageSet(tPage page, String? uid) async {
    //Logs.d('Sending $page - ${page.id.toString()}');
    try {
      final pageRef = FirebaseUtils.firestore
          .collection('stories')
          .doc(page.storyId)
          .collection('chapters')
          .doc(page.chapterId.toString())
          .collection('pages')
          .doc(page.id.toString());
      await FirebaseUtils.firestore.runTransaction((transaction) async {
        transaction.update(pageRef, {
          ...page.toMap(),
          ...{'lastModifierUid': uid},
        });
      });
    } catch (e) {
      Logs.d('Sending $page\n$e');
    }
  }

  Future<tPage?> pageGet(
    String storyId,
    String chapterId,
    String pageId,
  ) async {
    try {
      return tPage.fromMap((await FirebaseUtils.firestore
              .collection('stories')
              .doc(storyId)
              .collection('chapters')
              .doc(chapterId)
              .collection('pages')
              .doc(pageId)
              .get())
          .data());
    } catch (e) {
      print('pageGet: $e');
      return null;
    }
  }

  Future<void> pageCreate(tPage page, ChapterGraph newGraph) async {
    FirebaseUtils.firestore.runTransaction((transaction) async {
      transaction.update(
        FirebaseUtils.firestore
            .collection('stories')
            .doc(page.storyId)
            .collection('chapters')
            .doc(page.chapterId.toString()),
        {'graph': newGraph.toMap()},
      );
      transaction.set(
        FirebaseUtils.firestore
            .collection('stories')
            .doc(page.storyId)
            .collection('chapters')
            .doc(page.chapterId.toString())
            .collection('pages')
            .doc(page.id.toString()),
        {
          ...page.toMap(),
          ...{'lastModifierUid': null},
        },
      );
    });
  }

  Stream<List<Note>> commentThreadsStream(
    String storyId,
    String chapterId,
    String pageId,
  ) =>
      FirebaseUtils.firestore
          .collection('stories')
          .doc(storyId)
          .collection('chapters')
          .doc(chapterId)
          .collection('pages')
          .doc(pageId)
          .collection('notes')
          .snapshots()
          .asyncMap(
            (snapshot) =>
                snapshot.docs.map((map) => Note.fromMap(map.data())).toList(),
          );

  Stream<Change> streamPageChanges(
    String storyId,
    String chapterId,
    String pageId,
  ) {
    return FirebaseUtils.realtime
        .ref('stories/$storyId/chapters/$chapterId/pages/$pageId/changes')
        .onChildAdded
        .map((event) =>
            Change.fromMap(event.snapshot.value as Map<String, dynamic>));
  }

  Future<void> pushPageChange(
      String storyId, String chapterId, String pageId, Change change,
      {int? cursorPosition}) async {
    await FirebaseUtils.realtime
        .ref('stories/$storyId/chapters/$chapterId/pages/$pageId/changes')
        .push()
        .set(change.toMap());
    /*if (cursorPosition != null) {
      await FirebaseUtils.firestore
          .collection('stories')
          .doc(storyId)
          .collection('chapters')
          .doc(chapterId)
          .collection('pages')
          .doc(pageId)
          .update(
        {
          'cursors': {
            change.uid: cursorPosition,
          },
        },
      );
    }*/
  }

  Future<List<Change>> getPageChanges(
      String storyId, String chapterId, String pageId) async {
    return ((await FirebaseUtils.realtime
                .ref(
                    'stories/$storyId/chapters/$chapterId/pages/$pageId/changes')
                .once())
            .snapshot
            .value as List<Map<String, dynamic>>)
        .map((e) => Change.fromMap(e))
        .toList();
  }
}
