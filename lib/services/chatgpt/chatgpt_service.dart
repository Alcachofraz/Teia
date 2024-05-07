import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ChatGPTService extends GetxService {
  //final String apiKey = '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';
  final String apiKey = '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';

  final String apiHost = 'https://api.openai.com/v1/chat/completions';

  final String model = 'gpt-3.5-turbo';

  static final dio = Dio();

  Future<String> getDraft(String context) async {
    final body = {
      "model": model,
      "messages": [
        {
          "role": "user",
          "content":
              'I\'m writing a chapter for my book. This is what I have so far: "$context"',
        },
        {
          "role": "user",
          "content": "Tell me the next part of the story.",
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
  }
}
