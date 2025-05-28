import 'package:get_it/get_it.dart';

import 'data/repositories/connection_repository_impl.dart';
import 'domain/repositories/connection_repository.dart';
import 'presentation/bloc/connection_bloc.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<ConnectionRepository>(
        () => ConnectionRepositoryImpl(),
  );
  getIt.registerFactory(
        () => ConnectionBloc(getIt<ConnectionRepository>()),
  );
}