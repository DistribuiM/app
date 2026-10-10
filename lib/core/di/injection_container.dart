import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/usuario_repository_impl.dart';
import '../../features/clients/data/datasources/client_remote_data_source.dart';
import '../../features/clients/data/repositories/client_repository_impl.dart';
import '../../features/clients/domain/repositories/client_repository.dart';
import '../../features/clients/presentation/cubit/client_form_cubit.dart';
import '../../features/clients/presentation/cubit/client_list_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/usuario_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/usuario_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/deliveries/data/datasources/delivery_remote_data_source.dart';
import '../../features/deliveries/data/repositories/delivery_repository_impl.dart';
import '../../features/deliveries/domain/repositories/delivery_repository.dart';
import '../../features/deliveries/presentation/cubit/client_deliveries_cubit.dart';
import '../../features/deliveries/presentation/cubit/delivery_form_cubit.dart';
import '../../features/deliveries/presentation/cubit/delivery_list_cubit.dart';

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

  if (!getIt.isRegistered<ClientRemoteDataSource>()) {
    getIt.registerLazySingleton<ClientRemoteDataSource>(
      () => ClientRemoteDataSource(),
    );
  }

  if (!getIt.isRegistered<DeliveryRemoteDataSource>()) {
    getIt.registerLazySingleton<DeliveryRemoteDataSource>(
      () => DeliveryRemoteDataSource(),
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

  if (!getIt.isRegistered<UsuarioRepository>()) {
    getIt.registerLazySingleton<UsuarioRepository>(
      () => UsuarioRepositoryImpl(getIt<UsuarioRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<ClientRepository>()) {
    getIt.registerLazySingleton<ClientRepository>(
      () => ClientRepositoryImpl(getIt<ClientRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<DeliveryRepository>()) {
    getIt.registerLazySingleton<DeliveryRepository>(
      () => DeliveryRepositoryImpl(getIt<DeliveryRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<SessionCubit>()) {
    getIt.registerLazySingleton<SessionCubit>(
      () => SessionCubit(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<ClientListCubit>()) {
    getIt.registerFactory<ClientListCubit>(
      () => ClientListCubit(getIt<ClientRepository>()),
    );
  }

  if (!getIt.isRegistered<ClientFormCubit>()) {
    getIt.registerFactory<ClientFormCubit>(
      () => ClientFormCubit(getIt<ClientRepository>()),
    );
  }

  if (!getIt.isRegistered<DeliveryListCubit>()) {
    getIt.registerFactory<DeliveryListCubit>(
      () => DeliveryListCubit(getIt<DeliveryRepository>()),
    );
  }

  if (!getIt.isRegistered<ClientDeliveriesCubit>()) {
    getIt.registerFactory<ClientDeliveriesCubit>(
      () => ClientDeliveriesCubit(getIt<DeliveryRepository>()),
    );
  }

  if (!getIt.isRegistered<DeliveryFormCubit>()) {
    getIt.registerFactory<DeliveryFormCubit>(
      () => DeliveryFormCubit(
        getIt<DeliveryRepository>(),
        getIt<ClientRepository>(),
        getIt<UsuarioRepository>(),
      ),
    );
  }
}
