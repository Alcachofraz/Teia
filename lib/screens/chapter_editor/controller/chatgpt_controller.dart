import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teia/services/chatgpt/chatgpt_service.dart';

enum Language {
  english,
  portuguesePortugal;

  String get name {
    switch (this) {
      case Language.english:
        return 'english';
      case Language.portuguesePortugal:
        return 'portuguese from Portugal';
    }
  }

  String get code {
    switch (this) {
      case Language.english:
        return 'EN';
      case Language.portuguesePortugal:
        return 'PT';
    }
  }
}

class ChatGPTController extends GetxController {
  final Future<List<String>> Function() getChapterContent;
  ChatGPTController({required this.getChapterContent});
  RxString idea = ''.obs;
  RxBool loading = false.obs;
  RxBool loadingPrefs = true.obs;

  final ChatGPTService chatGPTService = Get.put(ChatGPTService());
  late SharedPreferences prefs;
  late Rx<Language> language;

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final lang = prefs.getInt('lang') ?? 0;
    language = Language.values[lang].obs;
    loadingPrefs.value = false;
  }

  @override
  void onInit() {
    loadPrefs();
    super.onInit();
  }

  Future<void> getIdea() async {
    loading.value = true;
    idea.value = await chatGPTService.getDraft(
      await getChapterContent(),
      language: language.value.name,
    );
    loading.value = false;
  }
}
