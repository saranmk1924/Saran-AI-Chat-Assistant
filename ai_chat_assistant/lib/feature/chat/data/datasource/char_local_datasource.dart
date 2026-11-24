import 'dart:convert';

import 'package:ai_chat_assistant/feature/chat/data/model/message_model.dart';
import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalDatasource {
  static const _key = 'chat_history_v1';
  static const _maxMessages = 100;

  final SharedPreferences prefs;

  ChatLocalDatasource(this.prefs);

  List<MessageModel> load() {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<MessageModel> messages) {
    var items = messages.where((m) => m.text.isNotEmpty).toList();
    if (items.length > _maxMessages) {
      items = items.sublist(items.length - _maxMessages);
    }
    while (items.isNotEmpty && items.first.role != MessageRole.user) {
      items.removeAt(0);
    }
    return prefs.setString(
      _key,
      jsonEncode(items.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> clear() => prefs.remove(_key);
}