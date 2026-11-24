import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String text;

  const SendMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class RetryEvent extends ChatEvent {
  const RetryEvent();
}

class StopGenerationEvent extends ChatEvent {
  const StopGenerationEvent();
}

class LoadHistoryEvent extends ChatEvent {
  const LoadHistoryEvent();
}

class ClearHistoryEvent extends ChatEvent {
  const ClearHistoryEvent();
}