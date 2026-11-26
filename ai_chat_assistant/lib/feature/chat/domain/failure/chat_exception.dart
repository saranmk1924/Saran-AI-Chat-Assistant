enum ChatErrorType {
  noInternet,
  timeout,
  rateLimit,
  overloaded,
  invalidKey,
  modelNotFound,
  blocked,
  emptyResponse,
  unknown,
}

class ChatException implements Exception {
  final ChatErrorType type;

  const ChatException(this.type);

  String get message => switch (type) {
    ChatErrorType.noInternet =>
      'No internet connection. Check your network and try again.',
    ChatErrorType.timeout => 'The request took too long. Please try again.',
    ChatErrorType.rateLimit =>
      'Free usage limit reached. Wait a minute and try again.',
    ChatErrorType.overloaded =>
      'The AI service is busy right now. Please try again.',
    ChatErrorType.invalidKey =>
      'Access was rejected. Check the app configuration.',
    ChatErrorType.modelNotFound =>
      'This AI model is unavailable. Try changing the model.',
    ChatErrorType.blocked =>
      'This request was blocked by the AI safety filters. Try rephrasing.',
    ChatErrorType.emptyResponse =>
      'The AI returned an empty answer. Please try again.',
    ChatErrorType.unknown => 'Something went wrong. Please try again.',
  };

  bool get canRetry => switch (type) {
    ChatErrorType.invalidKey ||
    ChatErrorType.modelNotFound ||
    ChatErrorType.blocked => false,
    _ => true,
  };
}
