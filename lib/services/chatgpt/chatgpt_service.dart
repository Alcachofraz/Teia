import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ChatGPTService extends GetxService {
  //final String apiKey = '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';
  //final String apiKey = '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';
  final String apiKey =
      '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';

  // final String apiHost = 'https://api.openai.com/v1/chat/completions';
  final String apiHost = 'https://api.groq.com/openai/v1/chat/completions';

  // final String model = 'gpt-3.5-turbo';
  final String model = 'llama3-8b-8192';

  static final dio = Dio();

  Future<String> getDraft(List<String> context) async {
    final List<dynamic> content = [
      {
        "role": "user",
        "content":
            "I will provide you with context for the previous pages of my Choose Your Own Adventure book, and you'll keep the story going. You must only generate the story content, and you must not answer like a chat-bot. The content you generate should be written in the same language as the context. You must write in second-person. The options you might provide are only narrative, there's no need to bullet point them.",
      },
      if (context.isNotEmpty) ...[
        for (String page in context)
          {
            "role": "user",
            "content": page,
          },
      ] else ...[
        {
          "role": "user",
          "content":
              "For now, there is no context, so you can start the story with total freedom.",
        },
      ],
    ];
    try {
      final body = {"model": model, "messages": content};
      final headers = {
        "Authorization": "Bearer $apiKey",
        "Accept": "application/json",
        "Content-Type": "application/json",
      };
      final response = await dio.post(
        apiHost,
        data: body,
        options: Options(
          headers: headers,
        ),
      );
      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      print(e);
      return '';
    }
  }
}
