class AppConfig {
  AppConfig._();

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  static const String geminiModel = 'gemini-3.5-flash';

  static bool get hasApiKey => geminiApiKey.isNotEmpty;
}