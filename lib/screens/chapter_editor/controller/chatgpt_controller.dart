import 'package:get/get.dart';
import 'package:teia/services/chatgpt/chatgpt_service.dart';

class ChatGPTController extends GetxController {
  final Future<List<String>> Function() getChapterContent;
  ChatGPTController({required this.getChapterContent});
  RxString idea = ''.obs;
  RxBool loading = false.obs;

  final ChatGPTService chatGPTService = Get.put(ChatGPTService());

  Future<void> getIdea() async {
    loading.value = true;
    idea.value = await chatGPTService.getDraft(await getChapterContent());
    loading.value = false;
  }
}
