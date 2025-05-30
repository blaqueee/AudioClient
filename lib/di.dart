import 'package:audio_client/core/services/dio_service.dart';
import 'package:audio_client/data/datasources/connection_datasource.dart';
import 'package:audio_client/data/datasources/customs_office_datasource.dart';
import 'package:audio_client/data/datasources/impl/connection_datasource_impl.dart';
import 'package:audio_client/data/datasources/impl/customs_office_datasource_impl.dart';
import 'package:audio_client/data/repositories/customs_office_repository_impl.dart';
import 'package:audio_client/domain/repositories/customs_office_repository.dart';
import 'package:audio_client/domain/usecases/fetch_child_customs_offices_usecase.dart';
import 'package:audio_client/domain/usecases/fetch_root_customs_offices_usecase.dart';
import 'package:audio_client/presentation/bloc/customs_office_cubit.dart';
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
  getIt.registerLazySingleton<ConnectionRepository>(() => ConnectionRepositoryImpl());
  getIt.registerLazySingleton<CustomsOfficeRepository>(() => CustomsOfficeRepositoryImpl(dataSource: getIt.call()));

  // Use cases
  getIt.registerLazySingleton(() => HandleCommandUseCase(getIt<ConnectionRepository>()));
  getIt.registerLazySingleton(() => FetchChildCustomsOfficesUseCase(getIt.call()));
  getIt.registerLazySingleton(() => FetchRootCustomsOfficesUseCase(getIt.call()));

  // Blocs
  getIt.registerFactory(() => ConnectionBloc(getIt<ConnectionRepository>(), getIt<ConnectionDataSource>()));
  getIt.registerFactory(() => WebSocketBloc(getIt<HandleCommandUseCase>()));
  getIt.registerFactory(() => CustomsOfficeTreeCubit(
      fetchChildNodesUseCase: getIt.call(),
      fetchRootNodesUseCase: getIt.call(),
      dio: DioService.dio,
  ));

  // Data sources
  getIt.registerLazySingleton<ConnectionDataSource>(() => ConnectionDataSourceImpl(dio: DioService.dio));
  getIt.registerLazySingleton<CustomsOfficeDataSource>(() => CustomsOfficeDataSourceImpl(dio: DioService.dio));


}