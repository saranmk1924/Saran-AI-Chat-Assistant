import 'package:ai_chat_assistant/core/network/proxy_client.dart';
import 'package:ai_chat_assistant/feature/chat/data/datasource/char_local_datasource.dart';
import 'package:ai_chat_assistant/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:ai_chat_assistant/feature/chat/data/repository/chat_repository_impl.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/clear_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/get_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/save_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  serviceLocator
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<Dio>(ProxyClient.create)
    ..registerLazySingleton(() => ChatRemoteDatasource(serviceLocator()))
    ..registerLazySingleton(() => ChatLocalDatasource(serviceLocator()))
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    ..registerLazySingleton(() => SendMessageUsecase(serviceLocator()))
    ..registerLazySingleton(() => GetHistoryUsecase(serviceLocator()))
    ..registerLazySingleton(() => SaveHistoryUsecase(serviceLocator()))
    ..registerLazySingleton(() => ClearHistoryUsecase(serviceLocator()))
    ..registerFactory(
      () => ChatBloc(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    );
}