import 'package:mobile_app_standard/domain/datasource/app_datebase.dart';
import 'package:mobile_app_standard/domain/http_client/ip.dart';
import 'package:mobile_app_standard/domain/http_client/websocket.dart';
import 'package:mobile_app_standard/domain/repositories/todo_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_app_standard/feature/home/bloc/websocket/websocket_bloc.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_bloc.dart'; // เปลี่ยนเป็นชื่อไฟล์ที่มี TodoRepository

final locator = GetIt.instance;

Future<void> initLocator() async {
  // Register AppDatabase
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Register Repository
  locator.registerLazySingleton<TodoRepositoryInterface>(
      () => TodoRepository(locator<AppDatabase>()));

  // Register HttpClient
  locator.registerLazySingleton<IpClient>(() => IpClient());

  // Register WebSocketClient
  locator.registerLazySingleton<WebSocketClient>(() => WebSocketClient());

  // Register Bloc
  locator.registerLazySingleton<TodoBloc>(() => TodoBloc());
  locator.registerLazySingleton<WebsocketBloc>(() => WebsocketBloc());
  locator.registerLazySingleton<LanguageBloc>(() => LanguageBloc());
}
