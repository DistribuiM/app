import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/clients/data/datasources/client_remote_data_source.dart';
import 'package:app_distribuim/features/clients/data/repositories/client_repository_impl.dart';
import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRemoteDataSource extends Mock
    implements ClientRemoteDataSource {}

void main() {
  late MockClientRemoteDataSource dataSource;
  late ClientRepositoryImpl repository;

  const nome = 'Cliente';
  const rua = 'Rua A';
  const complemento = '';
  const cidade = 'Cidade';
  const telefone = '11999999999';
  const idMotoristaResp = 'motorista-1';
  const nomeMotoristaResp = 'Motorista';

  final clientes = [
    Cliente(
      id: 'cliente-1',
      nome: nome,
      telefone: telefone,
      endereco: Endereco(
        rua: rua,
        complemento: complemento,
        cidade: cidade,
      ),
      saldoPendente: 0,
      idMotoristaResp: idMotoristaResp,
      nomeMotoristaResp: nomeMotoristaResp,
    ),
  ];

  setUp(() {
    dataSource = MockClientRemoteDataSource();
    repository = ClientRepositoryImpl(dataSource);
  });

  group('registrarCliente', () {
    test('relança a mesma Failure lançada pelo data source', () async {
      const failure = ValidationFailure('msg');
      when(
        () => dataSource.registrarCliente(
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: idMotoristaResp,
          nomeMotoristaResp: nomeMotoristaResp,
        ),
      ).thenThrow(failure);

      await expectLater(
        repository.registrarCliente(
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: idMotoristaResp,
          nomeMotoristaResp: nomeMotoristaResp,
        ),
        throwsA(same(failure)),
      );
    });

    test('converte Exception em ServerFailure com mensagem genérica', () async {
      when(
        () => dataSource.registrarCliente(
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: idMotoristaResp,
          nomeMotoristaResp: nomeMotoristaResp,
        ),
      ).thenThrow(Exception('x'));

      await expectLater(
        repository.registrarCliente(
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: idMotoristaResp,
          nomeMotoristaResp: nomeMotoristaResp,
        ),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível salvar o cliente. Tente novamente.',
          ),
        ),
      );
    });

    test('completa sem erro quando o data source tem sucesso', () async {
      when(
        () => dataSource.registrarCliente(
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: idMotoristaResp,
          nomeMotoristaResp: nomeMotoristaResp,
        ),
      ).thenAnswer((_) async {});

      await expectLater(
        repository.registrarCliente(
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: idMotoristaResp,
          nomeMotoristaResp: nomeMotoristaResp,
        ),
        completes,
      );
    });
  });

  group('buscarClientes', () {
    test('relança a mesma Failure lançada pelo data source', () async {
      const failure = ValidationFailure('msg');
      when(
        () => dataSource.buscarClientes(idMotorista: null),
      ).thenThrow(failure);

      await expectLater(
        repository.buscarClientes(),
        throwsA(same(failure)),
      );
    });

    test('converte Exception em ServerFailure com mensagem genérica', () async {
      when(
        () => dataSource.buscarClientes(idMotorista: null),
      ).thenThrow(Exception('x'));

      await expectLater(
        repository.buscarClientes(),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível carregar os clientes. Tente novamente.',
          ),
        ),
      );
    });

    test('devolve o resultado do data source em caso de sucesso', () async {
      when(
        () => dataSource.buscarClientes(idMotorista: null),
      ).thenAnswer((_) async => clientes);

      expect(await repository.buscarClientes(), same(clientes));
      verify(() => dataSource.buscarClientes(idMotorista: null)).called(1);
    });

    test('repassa idMotorista ao data source', () async {
      when(
        () => dataSource.buscarClientes(idMotorista: idMotoristaResp),
      ).thenAnswer((_) async => clientes);

      expect(
        await repository.buscarClientes(idMotorista: idMotoristaResp),
        same(clientes),
      );
      verify(
        () => dataSource.buscarClientes(idMotorista: idMotoristaResp),
      ).called(1);
    });
  });
}
