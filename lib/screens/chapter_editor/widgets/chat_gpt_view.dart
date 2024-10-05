import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/screens/chapter_editor/controller/chatgpt_controller.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:teia/views/teia_button.dart';

class ChatGPTView extends GetView<ChatGPTController> {
  const ChatGPTView(
      {super.key, required this.getChapterContent, this.accentColor});
  final Future<List<String>> Function() getChapterContent;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    //Get.delete<ChatGPTController>();
    Get.put(ChatGPTController(getChapterContent: getChapterContent));
    return Tile(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      radiusAll: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 24.0,
                ),
                SizedBox(width: 8),
                AutoSizeText(
                  'Need inspiration?',
                  minFontSize: 16,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(
              () => controller.loadingPrefs.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          for (final language in Language.values)
                            FilterChip(
                              label: CountryFlag.fromLanguageCode(
                                language.code,
                                width: 24,
                                height: 16,
                              ),
                              selected: controller.language.value == language,
                              onSelected: (bool value) {
                                controller.language.value = language;
                                controller.prefs.setInt('lang', language.index);
                              },
                            )
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            TeiaButton(
              text: 'Get an idea',
              onTap: controller.getIdea,
              color: accentColor,
            ),
            Obx(
              () => controller.idea.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SelectableText(
                        controller.idea.value,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13),
                        textAlign: TextAlign.start,
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
