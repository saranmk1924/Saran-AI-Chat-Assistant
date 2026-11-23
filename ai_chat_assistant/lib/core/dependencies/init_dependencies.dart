import 'package:ai_chat_assistant/core/network/gemini_client.dart';
import 'package:ai_chat_assistant/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:ai_chat_assistant/feature/chat/data/repository/chat_repository_impl.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

void initDependencies() {
  serviceLocator
    ..registerLazySingleton<Dio>(GeminiClient.create)
    ..registerLazySingleton(() => ChatRemoteDatasource(serviceLocator()))
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(() => SendMessageUsecase(serviceLocator()))
    ..registerFactory(() => ChatBloc(serviceLocator()));
}