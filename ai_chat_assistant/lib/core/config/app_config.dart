class AppConfig {
  AppConfig._();

  static const String proxyUrl = String.fromEnvironment('PROXY_URL');
  static const String appToken = String.fromEnvironment('APP_TOKEN');

  static bool get isConfigured => proxyUrl.isNotEmpty && appToken.isNotEmpty;
  // static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // static const String geminiBaseUrl =
  //     'https://generativelanguage.googleapis.com/v1beta';

  // static const String geminiModel = 'gemini-3.5-flash-lite';

  // static bool get hasApiKey => geminiApiKey.isNotEmpty;

  // static const String chatSystemPrompt =
  //     'You are a helpful, concise assistant. Answer clearly in simple language. '
  //     'You do not have access to the internet or live data. If a question needs '
  //     'current news, prices or recent events, say that your information may be '
  //     'outdated.';
}

///// MODELS /////
  // gemini-3.5-flash
  // gemini-3.8-flash
  // gemini-3.6-flash
  // gemini-3.5-flash-lite
  // gemini-3.1-flash-lite
  // gemini-3-flash-preview
  // gemma-4-31b-it / gemma-4-26b-a4b-it