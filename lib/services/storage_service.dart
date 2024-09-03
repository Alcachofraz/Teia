import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:teia/services/firebase/firestore_utils.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  Future<String> uploadImage(
      String story, String chapter, Uint8List image) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseUtils.storage.ref('$story/$chapter/$id.png').putData(image);
    return await FirebaseUtils.storage
        .ref('$story/$chapter/$id.png')
        .getDownloadURL();
  }
}
