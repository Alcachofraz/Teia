import 'package:get/get.dart';
import 'package:teia/services/chatgpt/chatgpt_service.dart';

class ChatGPTController extends GetxController {
  final String Function() getPageContent;
  ChatGPTController({required this.getPageContent});
  RxString idea = ''.obs;
  RxBool loading = false.obs;

  final ChatGPTService chatGPTService = Get.put(ChatGPTService());

  Future<void> getIdea() async {
    loading.value = true;
    idea.value = await chatGPTService.getDraft(getPageContent());
    loading.value = false;
  }
}
