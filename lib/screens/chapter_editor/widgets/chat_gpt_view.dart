import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/screens/chapter_editor/controller/chatgpt_controller.dart';
import 'package:teia/views/misc/tile.dart';
import 'package:teia/views/teia_button.dart';

class ChatGPTView extends GetView<ChatGPTController> {
  const ChatGPTView(
      {super.key, required this.getPageContent, this.accentColor});
  final String Function() getPageContent;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    Get.put(ChatGPTController(getPageContent: getPageContent));
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
                Text(
                  'Need inspiration?',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
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
