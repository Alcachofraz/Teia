import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:teia/models/story.dart';
import 'package:teia/services/chapter_management_service.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class StoryManagementService extends GetxService {
  static StoryManagementService get value => Get.find<StoryManagementService>();

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

  /// Create a new story with given [storyName].
  Future<String?> storyCreate(String storyName) async {
    try {
      DocumentReference storyRef =
          FirebaseUtils.firestore.collection('stories').doc();
      storyRef.set(Story.init(storyRef.id, storyName).toMap());
      return storyRef.id;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Add chapter with [id] to story with given [storyId].
  Future<void> storyAddChapter(Story story) async {
    await ChapterManagementService.value.chapterCreate(
      story.id,
      story.numberOfChapters + 1,
    );
    return await FirebaseUtils.firestore
        .collection('stories')
        .doc(story.id)
        .update({'numberOfChapters': FieldValue.increment(1)});
  }
}
