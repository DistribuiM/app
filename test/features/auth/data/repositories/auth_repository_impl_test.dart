import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app_distribuim/features/auth/data/datasources/usuario_remote_data_source.dart';
import 'package:app_distribuim/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUsuarioRemoteDataSource extends Mock
    implements UsuarioRemoteDataSource {}

void main() {
  const email = 'motorista@example.com';
  late MockAuthRemoteDataSource authRemoteDataSource;
  late MockUsuarioRemoteDataSource usuarioRemoteDataSource;
  late AuthRepositoryImpl repository;

  final usuario = Usuario(
    id: email,
    nome: 'Motorista',
    email: email,
    cargo: CargoUsuario.motorista,
  );

  setUp(() {
    authRemoteDataSource = MockAuthRemoteDataSource();
    usuarioRemoteDataSource = MockUsuarioRemoteDataSource();
    repository = AuthRepositoryImpl(
      authRemoteDataSource: authRemoteDataSource,
      usuarioRemoteDataSource: usuarioRemoteDataSource,
    );
  });

  test('converte erro do Google em AuthFailure sem verificar cadastro', () async {
    when(
      () => authRemoteDataSource.signInWithGoogle(),
    ).thenThrow(Exception('Falha no Google'));

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível entrar com o Google. Tente novamente.',
        ),
      ),
    );

    verifyNever(() => authRemoteDataSource.signOut());
    verifyNever(
      () => usuarioRemoteDataSource.buscarMotoristaPorId(any()),
    );
  });

  test('converte erro na busca em ServerFailure e faz signOut', () async {
    when(
      () => authRemoteDataSource.signInWithGoogle(),
    ).thenAnswer((_) async => email);
    when(
      () => usuarioRemoteDataSource.buscarMotoristaPorId(email),
    ).thenThrow(Exception('Falha na busca'));
    when(() => authRemoteDataSource.signOut()).thenAnswer((_) async {});

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível verificar seu cadastro. Verifique sua conexão e '
              'tente novamente.',
        ),
      ),
    );

    verify(() => authRemoteDataSource.signOut()).called(1);
  });

  test('mantém ServerFailure mesmo se signOut também falhar', () async {
    when(
      () => authRemoteDataSource.signInWithGoogle(),
    ).thenAnswer((_) async => email);
    when(
      () => usuarioRemoteDataSource.buscarMotoristaPorId(email),
    ).thenThrow(Exception('Falha na busca'));
    when(
      () => authRemoteDataSource.signOut(),
    ).thenThrow(Exception('Falha no signOut'));

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível verificar seu cadastro. Verifique sua conexão e '
              'tente novamente.',
        ),
      ),
    );

    verify(() => authRemoteDataSource.signOut()).called(1);
  });

  test('nega acesso quando o motorista não está cadastrado', () async {
    when(
      () => authRemoteDataSource.signInWithGoogle(),
    ).thenAnswer((_) async => email);
    when(
      () => usuarioRemoteDataSource.buscarMotoristaPorId(email),
    ).thenAnswer((_) async => null);
    when(() => authRemoteDataSource.signOut()).thenAnswer((_) async {});

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.message,
          'message',
          'Acesso Negado: O e-mail $email não está cadastrado como motorista.',
        ),
      ),
    );

    verify(() => authRemoteDataSource.signOut()).called(1);
  });

  test('devolve o motorista cadastrado sem fazer signOut', () async {
    when(
      () => authRemoteDataSource.signInWithGoogle(),
    ).thenAnswer((_) async => email);
    when(
      () => usuarioRemoteDataSource.buscarMotoristaPorId(email),
    ).thenAnswer((_) async => usuario);

    expect(await repository.signInWithGoogle(), same(usuario));

    verifyNever(() => authRemoteDataSource.signOut());
  });
}
