import 'dart:convert';

import 'package:get/get.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/chapter_graph.dart';
import 'package:teia/models/note/note.dart';
import 'package:teia/models/page.dart';
import 'package:teia/services/firebase/firestore_utils.dart';
import 'package:teia/utils/logs.dart';

class ChapterManagementService extends GetxService {
  static ChapterManagementService get value =>
      Get.put(ChapterManagementService());
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
          .asyncMap((doc) {
        try {
          return Chapter.fromMap(doc.data());
        } catch (e) {
          throw Exception('Error parsing chapter: $e');
        }
      });

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
          .asyncMap(
        (doc) {
          try {
            return tPage.fromMap(doc.data());
          } catch (e) {
            throw Exception('Error parsing page: $e');
          }
        },
      );

  Future<void> chapterSet(Chapter chapter) async {
    //Logs.d('Sending $page');
    try {
      FirebaseUtils.firestore
          .collection('stories')
          .doc(chapter.storyId.toString())
          .collection('chapters')
          .doc(chapter.id.toString())
          .set(chapter.toMap());
    } catch (e) {
      Logs.d('Sending $chapter\n$e');
    }
  }

  Future<void> chapterUpdate(Chapter chapter) async {
    //Logs.d('Sending $page');
    try {
      FirebaseUtils.firestore
          .collection('stories')
          .doc(chapter.storyId.toString())
          .collection('chapters')
          .doc(chapter.id.toString())
          .update(chapter.toMap());
    } catch (e) {
      Logs.d('Sending $chapter\n$e');
    }
  }

  Future<Chapter?> chapterGet(String storyId, String chapterId) async {
    try {
      return Chapter.fromMap((await FirebaseUtils.firestore
              .collection('stories')
              .doc(storyId)
              .collection('chapters')
              .doc(chapterId)
              .get())
          .data());
    } catch (e) {
      print('chapterGet: $e');
      return null;
    }
  }

  // Add chapter
  Future<void> chapterCreate(String storyId, int chapterId) async {
    try {
      await FirebaseUtils.firestore
          .collection('stories')
          .doc(storyId)
          .collection('chapters')
          .doc(chapterId.toString())
          .set(Chapter.create(chapterId, storyId, 'New chapter').toMap());
      await pageCreate(
        tPage.empty(
          1,
          chapterId,
          storyId,
        ),
        ChapterGraph.empty(),
      );
    } catch (e) {
      Logs.d('Creating chapter $chapterId\n$e');
    }
  }

  // Add chapter
  Future<void> chapterSetTitle(
      String storyId, String chapterId, String title) async {
    try {
      await FirebaseUtils.firestore
          .collection('stories')
          .doc(storyId)
          .collection('chapters')
          .doc(chapterId)
          .update({'title': title});
    } catch (e) {
      Logs.d('Updating chapter title $chapterId\n$e');
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

  Future<void> pageDelete(String storyId, int chapterId, int pageId) async {
    FirebaseUtils.firestore
        .collection('stories')
        .doc(storyId)
        .collection('chapters')
        .doc(chapterId.toString())
        .collection('pages')
        .doc(pageId.toString())
        .delete();
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
        .map((event) {
      try {
        return Change.fromMap(
          Map<String, dynamic>.from(event.snapshot.value as dynamic),
        );
      } catch (e) {
        print('Error parsing change: $e');
        throw Exception('Error parsing change: $e');
      }
    });
  }

  Future<void> pushPageChange(
      String storyId, String chapterId, String pageId, Change change,
      {int? cursorPosition}) async {
    try {
      await FirebaseUtils.realtime
          .ref('stories/$storyId/chapters/$chapterId/pages/$pageId/changes')
          .push()
          .set(change.toMap());
    } catch (e) {
      throw Exception('Error pushing change: $e');
    }
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

  Future<List<Change>> getPageChanges(String storyId, String chapterId) async {
    return ((await FirebaseUtils.realtime
                .ref('stories/$storyId/chapters/$chapterId/pages')
                .once())
            .snapshot
            .value as List<Map<String, dynamic>>)
        .map((e) => Change.fromMap(e))
        .toList();
  }
}
