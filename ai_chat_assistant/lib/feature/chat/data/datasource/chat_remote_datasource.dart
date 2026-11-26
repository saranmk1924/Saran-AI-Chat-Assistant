import 'dart:convert';

// import 'package:ai_chat_assistant/core/config/app_config.dart';
import 'package:ai_chat_assistant/feature/chat/data/model/message_model.dart';
import 'package:dio/dio.dart';
import 'package:ai_chat_assistant/feature/chat/domain/failure/chat_exception.dart';
import 'package:flutter/material.dart';

class ChatRemoteDatasource {
  final Dio dio;

  ChatRemoteDatasource(this.dio);

  Stream<String> streamMessage(List<MessageModel> history) async* {
    try {
      final response = await dio.post<ResponseBody>(
        '/',
        data: {'messages': history.map((m) => m.toProxyJson()).toList()},
        options: Options(responseType: ResponseType.stream),
      );

      final lines = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      var gotText = false;
      var blocked = false;

      await for (final line in lines) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty) continue;

        final json = jsonDecode(payload) as Map<String, dynamic>;
        if (_isBlocked(json)) blocked = true;

        final text = _extractText(json);
        if (text.isNotEmpty) {
          gotText = true;
          yield text;
        }
      }

      if (!gotText) {
        throw ChatException(
          blocked ? ChatErrorType.blocked : ChatErrorType.emptyResponse,
        );
      }
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.type} ${e.response?.statusCode} ${e.message}');
      throw _mapDioException(e);
    } on FormatException {
      throw const ChatException(ChatErrorType.unknown);
    }
  }

  bool _isBlocked(Map<String, dynamic> json) {
    if (json['promptFeedback']?['blockReason'] != null) return true;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return false;
    final reason = candidates[0]['finishReason'];
    return reason == 'SAFETY' ||
        reason == 'BLOCKLIST' ||
        reason == 'PROHIBITED_CONTENT';
  }

  ChatException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const ChatException(ChatErrorType.noInternet);
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ChatException(ChatErrorType.timeout);
      case DioExceptionType.badResponse:
        return ChatException(_typeFromStatus(e.response?.statusCode));
      default:
        return const ChatException(ChatErrorType.unknown);
    }
  }

  ChatErrorType _typeFromStatus(int? code) => switch (code) {
    429 => ChatErrorType.rateLimit,
    500 || 502 || 503 || 504 => ChatErrorType.overloaded,
    401 || 403 => ChatErrorType.invalidKey,
    404 => ChatErrorType.modelNotFound,
    _ => ChatErrorType.unknown,
  };

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
