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
  const id = 'cliente-1';
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
      endereco: Endereco(rua: rua, complemento: complemento, cidade: cidade),
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

      await expectLater(repository.buscarClientes(), throwsA(same(failure)));
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

  group('ouvirClientes', () {
    test('repassa o idMotorista exato ao data source', () async {
      when(
        () => dataSource.ouvirClientes(idMotorista: idMotoristaResp),
      ).thenAnswer((_) => Stream.value(clientes));

      await expectLater(
        repository.ouvirClientes(idMotorista: idMotoristaResp),
        emits(same(clientes)),
      );

      verify(
        () => dataSource.ouvirClientes(idMotorista: idMotoristaResp),
      ).called(1);
    });

    test('repassa null ao data source', () async {
      when(
        () => dataSource.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => Stream.value(clientes));

      await expectLater(
        repository.ouvirClientes(idMotorista: null),
        emits(same(clientes)),
      );

      verify(() => dataSource.ouvirClientes(idMotorista: null)).called(1);
    });

    test('repassa os dados recebidos pelo stream', () async {
      when(
        () => dataSource.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => Stream.value(clientes));

      await expectLater(repository.ouvirClientes(), emits(same(clientes)));
    });

    test('relança a mesma Failure emitida pelo stream', () async {
      const failure = ValidationFailure('msg');
      when(
        () => dataSource.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => Stream.error(failure));

      await expectLater(repository.ouvirClientes(), emitsError(same(failure)));
    });

    test('converte exceção do stream em ServerFailure', () async {
      when(
        () => dataSource.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => Stream.error(Exception('x')));

      await expectLater(
        repository.ouvirClientes(),
        emitsError(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível carregar os clientes. Tente novamente.',
          ),
        ),
      );
    });

    test('converte exceção ao criar o stream em ServerFailure', () async {
      when(
        () => dataSource.ouvirClientes(idMotorista: null),
      ).thenThrow(Exception('x'));

      await expectLater(
        repository.ouvirClientes(),
        emitsError(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível carregar os clientes. Tente novamente.',
          ),
        ),
      );
    });
  });

  group('atualizarCliente', () {
    test('relança a mesma Failure lançada pelo data source', () async {
      const failure = ValidationFailure('msg');
      when(
        () => dataSource.atualizarCliente(
          id: id,
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
        repository.atualizarCliente(
          id: id,
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
        () => dataSource.atualizarCliente(
          id: id,
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
        repository.atualizarCliente(
          id: id,
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
            'Não foi possível atualizar o cliente. Tente novamente.',
          ),
        ),
      );
    });

    test('completa e repassa os valores exatos com responsável', () async {
      when(
        () => dataSource.atualizarCliente(
          id: id,
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
        repository.atualizarCliente(
          id: id,
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
      verify(
        () => dataSource.atualizarCliente(
          id: id,
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: idMotoristaResp,
          nomeMotoristaResp: nomeMotoristaResp,
        ),
      ).called(1);
    });

    test('repassa null explícito quando não há responsável', () async {
      when(
        () => dataSource.atualizarCliente(
          id: id,
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: null,
          nomeMotoristaResp: null,
        ),
      ).thenAnswer((_) async {});

      await repository.atualizarCliente(
        id: id,
        nome: nome,
        rua: rua,
        complemento: complemento,
        cidade: cidade,
        telefone: telefone,
      );

      verify(
        () => dataSource.atualizarCliente(
          id: id,
          nome: nome,
          rua: rua,
          complemento: complemento,
          cidade: cidade,
          telefone: telefone,
          idMotoristaResp: null,
          nomeMotoristaResp: null,
        ),
      ).called(1);
    });
  });
}
