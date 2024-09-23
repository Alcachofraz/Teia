import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_database/firebase_database.dart' as rt;
import 'package:get/get.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/models/chapter_graph.dart';
import 'package:teia/models/comment.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippets/snippet.dart';
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
        ChapterTree.empty(),
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

  Future<void> pageCreate(tPage page, ChapterTree newGraph) async {
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

  Future<List<Change>> getPageChanges(
      String storyId, String chapterId, String pageId) async {
    final rt.DatabaseReference ref = FirebaseUtils.realtime
        .ref('stories/$storyId/chapters/$chapterId/pages/$pageId/changes');
    final data = await ref.get();
    if (!data.exists) return [];
    return (data.value as List<dynamic>)
        .map((e) => Change.fromMap(jsonDecode(jsonEncode(e))))
        .toList();
  }

  // Returns a list with two Strings:
  // 1. The content of the page
  // 2. The text that leads to page [nextPageId]
  Future<List<String>> getPageContent(
      String storyId, String chapterId, String pageId,
      {String? nextPageId}) async {
    List<Change> changes = await getPageChanges(storyId, chapterId, pageId);
    tPage page = tPage.empty(0, 0, '');
    for (Change change in changes) {
      page.compose(change);
    }
    if (nextPageId != null) {
      String text = '';
      for (Letter letter in page.letters) {
        if (letter.snippet != null &&
            letter.snippet!.type == SnippetType.choice &&
            letter.snippet!.attributes['choice'] == int.parse(nextPageId)) {
          text += letter.letter;
        }
      }
      return [text, page.getRawText()];
    }
    return ['', page.getRawText()];
  }

  /// Simplify changes queue:
  Future<void> simplifyChangesQueue(tPage page) async {
    final postRef = FirebaseUtils.realtime.ref(
        'stories/${page.storyId}/chapters/${page.chapterId.toString()}/pages/${page.id}/changes');
    await postRef.runTransaction((post) {
      final Map<String, dynamic> newPost = {};
      int i = 0;
      for (Change change in page.toChanges()) {
        newPost[(i++).toString()] = change.toMap();
      }
      return rt.Transaction.success(newPost);
    });
  }

  // Push new comment and return ID
  Future<String> createComment(Comment comment) async {
    return (await FirebaseUtils.firestore
            .collection('stories')
            .doc(comment.storyId)
            .collection('chapters')
            .doc(comment.chapterId)
            .collection('pages')
            .doc(comment.pageId)
            .collection('comments')
            .add(comment.toJson()))
        .id;
  }

  // Push new message to comment [comment]
  Future<void> addCommentMessage(
    Comment comment,
    String message,
    int avatar,
    String username,
    String uid,
  ) async {
    return FirebaseUtils.firestore
        .collection('stories')
        .doc(comment.storyId)
        .collection('chapters')
        .doc(comment.chapterId)
        .collection('pages')
        .doc(comment.pageId)
        .collection('comments')
        .doc(comment.id)
        .update(
      {
        'messages': fs.FieldValue.arrayUnion([
          {
            'message': message,
            'avatar': avatar,
            'username': username,
            'uid': uid,
          }
        ]),
      },
    );
  }

  // Remove comment:
  Future<void> removeComment(Comment comment) async {
    return FirebaseUtils.firestore
        .collection('stories')
        .doc(comment.storyId)
        .collection('chapters')
        .doc(comment.chapterId)
        .collection('pages')
        .doc(comment.pageId)
        .collection('comments')
        .doc(comment.id)
        .delete();
  }

  // Stream changes to comments
  Stream<List<Comment>> streamCommentsChanges(
    String storyId,
    String chapterId,
    String pageId,
  ) {
    return FirebaseUtils.firestore
        .collection(
            'stories/$storyId/chapters/$chapterId/pages/$pageId/comments')
        .snapshots()
        .map((event) {
      try {
        return event.docs.map((e) => Comment.fromJson(e.data(), e.id)).toList();
      } catch (e) {
        print('Error parsing comments: $e');
        throw Exception('Error parsing comments: $e');
      }
    });
  }
}
