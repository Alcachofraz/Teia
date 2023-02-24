import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class ChapterEditService {
  static Stream<DocumentSnapshot<Map<String, dynamic>>> pageStream(
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
          .snapshots();
}
