import 'package:audio_client/core/services/dio_service.dart';
import 'package:audio_client/data/datasources/connection_datasource.dart';
import 'package:audio_client/data/datasources/impl/connection_datasource_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/db_service.dart';
import 'data/repositories/connection_repository_impl.dart';
import 'domain/repositories/connection_repository.dart';
import 'domain/usecases/handle_command_usecase.dart';
import 'presentation/bloc/connection_bloc.dart';
import 'presentation/bloc/websocket_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  DBService.init(
      cache: await SharedPreferences.getInstance(),
  );

  // Repositories
  getIt.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => HandleCommandUseCase(getIt<ConnectionRepository>()),
  );

  // Blocs
  getIt.registerFactory(
    () => ConnectionBloc(getIt<ConnectionRepository>(), getIt<ConnectionDataSource>()),
  );
  getIt.registerFactory(
    () => WebSocketBloc(getIt<HandleCommandUseCase>()),
  );

  // Data sources
  getIt.registerLazySingleton<ConnectionDataSource>(
    () => ConnectionDataSourceImpl(dio: DioService.dio)
  );


}