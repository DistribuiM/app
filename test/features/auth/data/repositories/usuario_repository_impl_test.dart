import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/data/datasources/usuario_remote_data_source.dart';
import 'package:app_distribuim/features/auth/data/repositories/usuario_repository_impl.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsuarioRemoteDataSource extends Mock
    implements UsuarioRemoteDataSource {}

void main() {
  late MockUsuarioRemoteDataSource dataSource;
  late UsuarioRepositoryImpl repository;

  final motoristas = [
    Usuario(
      id: 'motorista-1',
      nome: 'Motorista',
      email: 'motorista@example.com',
      cargo: CargoUsuario.motorista,
    ),
  ];

  setUp(() {
    dataSource = MockUsuarioRemoteDataSource();
    repository = UsuarioRepositoryImpl(dataSource);
  });

  test('relança a mesma Failure lançada pelo data source', () async {
    const failure = ValidationFailure('msg');
    when(() => dataSource.buscarMotoristas()).thenThrow(failure);

    await expectLater(repository.buscarMotoristas(), throwsA(same(failure)));
  });

  test('converte Exception em ServerFailure com mensagem genérica', () async {
    when(() => dataSource.buscarMotoristas()).thenThrow(Exception('x'));

    await expectLater(
      repository.buscarMotoristas(),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível carregar os motoristas.',
        ),
      ),
    );
  });

  test('devolve o resultado do data source em caso de sucesso', () async {
    when(
      () => dataSource.buscarMotoristas(),
    ).thenAnswer((_) async => motoristas);

    expect(await repository.buscarMotoristas(), equals(motoristas));
  });

  test('retorna somente motoristas preservando a ordem', () async {
    final motoristaUm = motoristas.first;
    final admin = Usuario(
      id: 'admin-1',
      nome: 'Admin',
      email: 'admin@example.com',
      cargo: CargoUsuario.admin,
    );
    final motoristaDois = Usuario(
      id: 'motorista-2',
      nome: 'Outro motorista',
      email: 'outro@example.com',
      cargo: CargoUsuario.motorista,
    );
    when(
      () => dataSource.buscarMotoristas(),
    ).thenAnswer((_) async => [motoristaUm, admin, motoristaDois]);

    expect(
      await repository.buscarMotoristas(),
      equals([motoristaUm, motoristaDois]),
    );
  });

  test('retorna todos quando a lista contém somente motoristas', () async {
    final outroMotorista = Usuario(
      id: 'motorista-2',
      nome: 'Outro motorista',
      email: 'outro@example.com',
      cargo: CargoUsuario.motorista,
    );
    when(
      () => dataSource.buscarMotoristas(),
    ).thenAnswer((_) async => [motoristas.first, outroMotorista]);

    expect(
      await repository.buscarMotoristas(),
      equals([motoristas.first, outroMotorista]),
    );
  });

  test('retorna lista vazia quando não há motoristas', () async {
    when(
      () => dataSource.buscarMotoristas(),
    ).thenAnswer((_) async => <Usuario>[]);

    expect(await repository.buscarMotoristas(), isEmpty);
  });
}
