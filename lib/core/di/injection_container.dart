import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/usuario_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  }

  if (!getIt.isRegistered<UsuarioRemoteDataSource>()) {
    getIt.registerLazySingleton<UsuarioRemoteDataSource>(
      () => UsuarioRemoteDataSource(),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDataSource: getIt<AuthRemoteDataSource>(),
        usuarioRemoteDataSource: getIt<UsuarioRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  }
}
