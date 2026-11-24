import 'package:ai_chat_assistant/core/config/app_config.dart';
// import 'package:ai_chat_assistant/core/network/gemini_client.dart';
// import 'package:dio/dio.dart';
import 'package:ai_chat_assistant/core/dependencies/init_dependencies.dart';
// import 'package:ai_chat_assistant/core/network/gemini_client.dart';
import 'package:ai_chat_assistant/core/theme/app_theme.dart';
// import 'package:ai_chat_assistant/feature/chat/data/datasource/chat_remote_datasource.dart';
// import 'package:ai_chat_assistant/feature/chat/data/repository/chat_repository_impl.dart';
// import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_event.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/pages/chat_page.dart';
// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  debugPrint('API key loaded: ${AppConfig.hasApiKey}');
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

  // final repo = ChatRepositoryImpl(ChatRemoteDatasource(GeminiClient.create()));
  // final history = [
  //   const MessageEntity(
  //     id: '1',
  //     role: MessageRole.user,
  //     text: 'Explain Clean Architecture in 5 sentences.',
  //   ),
  // ];

  // try {
  //   await for (final piece in repo.sendMessage(history)) {
  //     debugPrint('PIECE: $piece');
  //   }
  // } on DioException catch (e) {
  //   debugPrint('Gemini error: ${e.response?.statusCode}');
  // }
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saran AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: BlocProvider(
        create: (_) =>
            serviceLocator<ChatBloc>()..add(const LoadHistoryEvent()),
        child: const ChatPage(),
      ),
    );
  }
}
