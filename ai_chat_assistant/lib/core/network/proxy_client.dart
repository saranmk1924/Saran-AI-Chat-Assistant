import 'package:ai_chat_assistant/core/config/app_config.dart';
import 'package:dio/dio.dart';

class ProxyClient {
  ProxyClient._();

  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.proxyUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-app-token': AppConfig.appToken,
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }
}