import 'dart:convert';

import 'package:ai_chat_assistant/core/config/app_config.dart';
import 'package:ai_chat_assistant/feature/chat/data/model/message_model.dart';
import 'package:dio/dio.dart';

class ChatRemoteDatasource {
  final Dio dio;

  ChatRemoteDatasource(this.dio);

  Stream<String> streamMessage(List<MessageModel> history) async* {
    final response = await dio.post<ResponseBody>(
      '/models/${AppConfig.geminiModel}:streamGenerateContent',
      queryParameters: {'alt': 'sse'},
      data: {
        'system_instruction': {
          'parts': [
            {'text': AppConfig.chatSystemPrompt},
          ],
        },
        'contents': history.map((m) => m.toGeminiJson()).toList(),
      },
      options: Options(responseType: ResponseType.stream),
    );

    final lines = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty) continue;

      final json = jsonDecode(payload) as Map<String, dynamic>;
      final text = _extractText(json);
      if (text.isNotEmpty) yield text;
    }
  }

  String _extractText(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return '';

    final parts = (candidates[0]['content']?['parts'] as List<dynamic>?) ?? [];
    return parts
        .where((p) => p['thought'] != true)
        .map((p) => p['text'] as String? ?? '')
        .join();
  }
}
