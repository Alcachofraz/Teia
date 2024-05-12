import 'package:get/get.dart';
import 'package:teia/models/story.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class StoryManagementService extends GetxService {
  /// Get story with given [storyId].
  Future<Story?> storyGet(String? storyId) async {
    if (storyId == null) {
      return null;
    }
    final query =
        await FirebaseUtils.firestore.collection('stories').doc(storyId).get();
    return Story.fromMap(query.data()!);
  }
}
