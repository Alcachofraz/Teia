import 'package:teia/models/page.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class ChapterEditService {
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
          .map((doc) => Page.fromMap(doc.data()));

  static Future<void> pageUpdate(Page page) {
    FirebaseUtils.firestore
        .collection('stories')
        .doc(page.storyId)
        .collection('chapters')
        .doc(page.chapterId.toString())
        .collection('pages')
        .doc(page.id.toString())
        .set(page.toMap());
  }
}
