import 'package:teia/models/chapter.dart';
import 'package:teia/models/chapter_graph.dart';
import 'package:teia/models/editing_page.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class ChapterManagementService {
  static Stream<Chapter> chapterStream(
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

  static Stream<EditingPage> pageStream(
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
          .asyncMap((doc) => EditingPage.fromMap(doc.data()));

  static Future<void> chapterSet(Chapter chapter) async {
    //Logs.d('Sending $page');
    FirebaseUtils.firestore.collection('stories').doc(chapter.storyId).collection('chapters').doc(chapter.id.toString()).set(chapter.toMap());
  }

  static Future<void> pageSet(EditingPage page, String uid) async {
    //Logs.d('Sending $page');
    FirebaseUtils.firestore
        .collection('stories')
        .doc(page.storyId)
        .collection('chapters')
        .doc(page.chapterId.toString())
        .collection('pages')
        .doc(page.id.toString())
        .set({
      ...page.toMap(),
      ...{'lastModifierUid': uid},
    });
  }

  static Future<void> pageCreate(EditingPage page, ChapterGraph newGraph) async {
    FirebaseUtils.firestore.runTransaction((transaction) async {
      transaction.update(
        FirebaseUtils.firestore.collection('stories').doc(page.storyId).collection('chapters').doc(page.chapterId.toString()),
        {'graph': newGraph.toMap()},
      );
      transaction.update(
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

  /*static Stream<Chapter> chapterStream(
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

  static Stream<Page> pageStream(
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
          .asyncMap((doc) => Page.fromMap(doc.data()));

  static Future<void> chapterSet(Chapter chapter) async {
    //Logs.d('Sending $page');
    FirebaseUtils.firestore
        .collection('stories')
        .doc(chapter.storyId)
        .collection('chapters')
        .doc(chapter.id.toString())
        .set(chapter.toMap());
  }

  static Future<void> pageSet(Page page, String uid) async {
    //Logs.d('Sending $page');
    FirebaseUtils.firestore
        .collection('stories')
        .doc(page.storyId)
        .collection('chapters')
        .doc(page.chapterId.toString())
        .collection('pages')
        .doc(page.id.toString())
        .set({
      ...page.toMap(),
      ...{'lastModifierUid': uid},
    });
  }

  static Future<void> pageCreate(Page page, ChapterGraph newGraph) async {
    //Logs.d('Sending $page');
    FirebaseUtils.firestore
        .collection('stories')
        .doc(page.storyId)
        .collection('chapters')
        .doc(page.chapterId.toString())
        .collection('pages')
        .doc(page.id.toString())
        .set({
      ...page.toMap(),
      ...{'lastModifierUid': null},
    });

    FirebaseUtils.firestore
        .collection('stories')
        .doc(page.storyId)
        .collection('chapters')
        .doc(page.chapterId.toString())
        .update({
      'graph': newGraph.nodes,
    });
  }*/
}
