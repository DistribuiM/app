import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  blocTest<AuthCubit, AuthState>(
    'emite loading e initial quando signInWithGoogle tem sucesso',
    build: () {
      when(
        () => authRepository.signInWithGoogle(),
      ).thenAnswer(
        (_) async => Usuario(
          id: 'motorista@example.com',
          nome: 'Motorista',
          email: 'motorista@example.com',
          cargo: CargoUsuario.motorista,
        ),
      );
      return AuthCubit(authRepository);
    },
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => [AuthLoading(), AuthInitial()],
    verify: (_) => verify(() => authRepository.signInWithGoogle()).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'emite loading e erro quando signInWithGoogle falha',
    build: () {
      when(
        () => authRepository.signInWithGoogle(),
      ).thenThrow(Exception('Falha na autenticação'));
      return AuthCubit(authRepository);
    },
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => [
      AuthLoading(),
      const AuthError('Falha na autenticação'),
    ],
    verify: (_) => verify(() => authRepository.signInWithGoogle()).called(1),
  );
}
