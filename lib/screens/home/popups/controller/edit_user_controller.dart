import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';

class EditUserController extends GetxController {
  final Group group;
  EditUserController({
    required this.group,
  });
  RxList<String> availableAvatars = <String>[].obs;

  @override
  void onInit() {
    List<int> avatars = ArtService.value.avatarIndexes();
    List<int> usedAvatars = [];
    group.userState.forEach((key, value) {
      if (key != AuthenticationService.value.user!.uid) {
        usedAvatars.add(value.avatar);
      }
    });
    availableAvatars.value = avatars
        .where((element) => !usedAvatars.contains(element))
        .map((e) => ArtService.value.assetPath(e))
        .toList();
    super.onInit();
  }
}
