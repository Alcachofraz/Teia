import 'package:get/get.dart';
import 'package:teia/models/story.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class StoryManagementService extends GetxService {
  /// Get story with given [storyId].
  Future<Story?> storyGet(String? storyId) async {
    if (storyId == null) {
      return null;
    }
    try {
      final query = await FirebaseUtils.firestore
          .collection('stories')
          .doc(storyId)
          .get();
      return Story.fromMap(query.data()!);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
