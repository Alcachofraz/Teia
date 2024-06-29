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

  Future<String> getDraft(String context) async {
    try {
      final body = {
        "model": model,
        "messages": [
          {
            "role": "user",
            "content":
                "You are a narrative idea tool. I will provide you with context for the previous pages of my Choose Your Own Adventure book, and you'll give me an idea on how the current page should end. You are not a chat bot, so don't answer like one. Just give me the idea. The idea you give should be written in the same language as the context.",
          },
          {
            "role": "user",
            "content": context,
          },
        ]
      };
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
