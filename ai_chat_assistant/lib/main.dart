import 'package:ai_chat_assistant/core/config/app_config.dart';
import 'package:ai_chat_assistant/core/network/gemini_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // debugPrint('API key loaded: ${AppConfig.hasApiKey}');
  // final dio = GeminiClient.create();
  // try {
  //   final res = await dio.post(
  //     '/models/${AppConfig.geminiModel}:generateContent',
  //     data: {
  //       'contents': [
  //         {
  //           'role': 'user',
  //           'parts': [
  //             {'text': 'What is BLoC in one sentence?'},
  //           ],
  //         },
  //       ],
  //     },
  //   );
  //   debugPrint(res.data['candidates'][0]['content']['parts'][0]['text']);
  // } on DioException catch (e) {
  //   debugPrint('Gemini error: ${e.response?.statusCode}');
  // }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Colors.purple),
    );
  }
}
