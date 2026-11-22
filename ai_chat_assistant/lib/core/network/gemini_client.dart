import 'package:ai_chat_assistant/core/config/app_config.dart';
import 'package:dio/dio.dart';

class GeminiClient {
  GeminiClient._();

  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.geminiBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': AppConfig.geminiApiKey,
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }
}