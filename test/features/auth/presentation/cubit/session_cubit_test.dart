import 'dart:async';

import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_cubit.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late StreamController<Usuario?> sessionChanges;

  setUp(() {
    authRepository = MockAuthRepository();
    sessionChanges = StreamController<Usuario?>();
    when(
      () => authRepository.sessionChanges,
    ).thenAnswer((_) => sessionChanges.stream);
  });

  tearDown(() async {
    await sessionChanges.close();
  });

  final usuario = Usuario(
    id: 'motorista@example.com',
    nome: 'Motorista',
    email: 'motorista@example.com',
    cargo: CargoUsuario.motorista,
  );

  blocTest<SessionCubit, SessionState>(
    'emite SessionAuthenticated ao receber um usuario',
    build: () => SessionCubit(authRepository),
    act: (_) => sessionChanges.add(usuario),
    expect: () => [SessionAuthenticated(usuario)],
  );

  blocTest<SessionCubit, SessionState>(
    'emite SessionUnauthenticated ao receber null',
    build: () => SessionCubit(authRepository),
    act: (_) => sessionChanges.add(null),
    expect: () => [SessionUnauthenticated()],
  );

  blocTest<SessionCubit, SessionState>(
    'emite SessionUnauthenticated e faz signOut quando a stream falha',
    setUp: () {
      when(() => authRepository.signOut()).thenAnswer((_) async {});
    },
    build: () => SessionCubit(authRepository),
    act: (_) => sessionChanges.addError(Exception('Falha de conexão')),
    expect: () => [SessionUnauthenticated()],
    verify: (_) => verify(() => authRepository.signOut()).called(1),
  );

  blocTest<SessionCubit, SessionState>(
    'continua recebendo dados depois de um erro na stream',
    setUp: () {
      when(() => authRepository.signOut()).thenAnswer((_) async {});
    },
    build: () => SessionCubit(authRepository),
    act: (_) {
      sessionChanges
        ..addError(Exception('Falha de conexão'))
        ..add(usuario);
    },
    expect: () => [SessionUnauthenticated(), SessionAuthenticated(usuario)],
    verify: (_) => verify(() => authRepository.signOut()).called(1),
  );
}
