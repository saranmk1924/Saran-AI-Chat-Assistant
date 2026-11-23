import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant }

class MessageEntity extends Equatable {
  final String id;
  final MessageRole role;
  final String text;

  const MessageEntity({
    required this.id,
    required this.role,
    required this.text,
  });

  MessageEntity copyWith({String? text}) {
    return MessageEntity(id: id, role: role, text: text ?? this.text);
  }

  @override
  List<Object?> get props => [id, role, text];
}