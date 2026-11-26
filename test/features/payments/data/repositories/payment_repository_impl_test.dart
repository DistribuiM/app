import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:app_distribuim/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRemoteDataSource extends Mock
    implements PaymentRemoteDataSource {}

void main() {
  late MockPaymentRemoteDataSource dataSource;
  late PaymentRepositoryImpl repository;

  const data = '04/11/2026';
  const idMotorista = 'motorista-1';
  const nomeMotorista = 'Motorista';
  const idCliente = 'cliente-1';
  const nomeCliente = 'Cliente';
  const cidadeCliente = 'Cidade';
  const valor = 50.5;
  const formaPagamento = 'Pix';
  final pagamento = Pagamento(
    id: 'pagamento-1',
    data: data,
    idMotorista: idMotorista,
    nomeMotorista: nomeMotorista,
    idCliente: idCliente,
    nomeCliente: nomeCliente,
    cidadeCliente: cidadeCliente,
    valor: valor,
    formaPagamento: formaPagamento,
  );

  setUp(() {
    dataSource = MockPaymentRemoteDataSource();
    repository = PaymentRepositoryImpl(dataSource);
  });

  test('relança a mesma Failure do data source', () async {
    const failure = ValidationFailure('Falha');
    when(
      () => dataSource.registrarPagamento(
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        valor: valor,
        formaPagamento: formaPagamento,
      ),
    ).thenThrow(failure);

    await expectLater(_registrarPagamento(repository), throwsA(same(failure)));
  });

  test('converte Exception em ServerFailure', () async {
    when(
      () => dataSource.registrarPagamento(
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        valor: valor,
        formaPagamento: formaPagamento,
      ),
    ).thenThrow(Exception('Falha técnica'));

    await expectLater(
      _registrarPagamento(repository),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível registrar o pagamento. Tente novamente.',
        ),
      ),
    );
  });

  test('completa e repassa os valores exatos ao data source', () async {
    when(
      () => dataSource.registrarPagamento(
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        valor: valor,
        formaPagamento: formaPagamento,
      ),
    ).thenAnswer((_) async {});

    await expectLater(_registrarPagamento(repository), completes);

    verify(
      () => dataSource.registrarPagamento(
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        valor: valor,
        formaPagamento: formaPagamento,
      ),
    ).called(1);
  });

  test('atualiza pagamento repassando os campos editáveis', () async {
    when(
      () => dataSource.atualizarPagamento(
        id: 'pagamento-1',
        data: '05/11/2026',
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        valor: 70,
        formaPagamento: 'Dinheiro',
      ),
    ).thenAnswer((_) async {});

    await expectLater(
      repository.atualizarPagamento(
        id: 'pagamento-1',
        data: '05/11/2026',
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        valor: 70,
        formaPagamento: 'Dinheiro',
      ),
      completes,
    );

    verify(
      () => dataSource.atualizarPagamento(
        id: 'pagamento-1',
        data: '05/11/2026',
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        valor: 70,
        formaPagamento: 'Dinheiro',
      ),
    ).called(1);
  });

  test('rejeita valor inválido antes de acessar o data source', () async {
    await expectLater(
      repository.atualizarPagamento(
        id: 'pagamento-1',
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        valor: double.nan,
        formaPagamento: formaPagamento,
      ),
      throwsA(isA<ValidationFailure>()),
    );

    verifyNever(
      () => dataSource.atualizarPagamento(
        id: any(named: 'id'),
        data: any(named: 'data'),
        idMotorista: any(named: 'idMotorista'),
        nomeMotorista: any(named: 'nomeMotorista'),
        valor: any(named: 'valor'),
        formaPagamento: any(named: 'formaPagamento'),
      ),
    );
  });

  test('converte erro técnico ao atualizar em ServerFailure', () async {
    when(
      () => dataSource.atualizarPagamento(
        id: 'pagamento-1',
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        valor: valor,
        formaPagamento: formaPagamento,
      ),
    ).thenThrow(Exception('Falha técnica'));

    await expectLater(
      _atualizarPagamento(repository),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível atualizar o pagamento. Tente novamente.',
        ),
      ),
    );
  });

  test('exclui pagamento e repassa o id ao data source', () async {
    when(
      () => dataSource.excluirPagamento('pagamento-1'),
    ).thenAnswer((_) async {});

    await expectLater(repository.excluirPagamento('pagamento-1'), completes);

    verify(() => dataSource.excluirPagamento('pagamento-1')).called(1);
  });

  test('preserva Failure ao excluir pagamento', () async {
    const failure = ValidationFailure('Pagamento não encontrado.');
    when(() => dataSource.excluirPagamento('pagamento-1')).thenThrow(failure);

    await expectLater(
      repository.excluirPagamento('pagamento-1'),
      throwsA(same(failure)),
    );
  });

  test('ouve pagamentos e repassa o filtro de motorista', () async {
    when(
      () => dataSource.ouvirPagamentos(idMotorista: idMotorista),
    ).thenAnswer((_) => Stream.value([pagamento]));

    await expectLater(
      repository.ouvirPagamentos(idMotorista: idMotorista),
      emits([same(pagamento)]),
    );

    verify(
      () => dataSource.ouvirPagamentos(idMotorista: idMotorista),
    ).called(1);
  });

  test('ouve somente pagamentos do cliente solicitado', () async {
    when(
      () => dataSource.ouvirPagamentosDoCliente(idCliente),
    ).thenAnswer((_) => Stream.value([pagamento]));

    await expectLater(
      repository.ouvirPagamentosDoCliente(idCliente),
      emits([same(pagamento)]),
    );

    verify(() => dataSource.ouvirPagamentosDoCliente(idCliente)).called(1);
  });

  test(
    'converte erro técnico dos pagamentos do cliente em ServerFailure',
    () async {
      when(
        () => dataSource.ouvirPagamentosDoCliente(idCliente),
      ).thenAnswer((_) => Stream.error(Exception('Falha técnica')));

      await expectLater(
        repository.ouvirPagamentosDoCliente(idCliente),
        emitsError(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível carregar os pagamentos do cliente. Tente novamente.',
          ),
        ),
      );
    },
  );

  test('ouve um pagamento específico pelo id', () async {
    when(
      () => dataSource.ouvirPagamento('pagamento-1'),
    ).thenAnswer((_) => Stream.value(pagamento));

    await expectLater(
      repository.ouvirPagamento('pagamento-1'),
      emits(same(pagamento)),
    );

    verify(() => dataSource.ouvirPagamento('pagamento-1')).called(1);
  });

  test(
    'converte erros técnicos ao ouvir um pagamento em ServerFailure',
    () async {
      when(
        () => dataSource.ouvirPagamento('pagamento-1'),
      ).thenAnswer((_) => Stream.error(Exception('Falha técnica')));

      await expectLater(
        repository.ouvirPagamento('pagamento-1'),
        emitsError(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível carregar o pagamento. Tente novamente.',
          ),
        ),
      );
    },
  );

  test('converte erros técnicos do stream em ServerFailure', () async {
    when(
      () => dataSource.ouvirPagamentos(idMotorista: null),
    ).thenAnswer((_) => Stream.error(Exception('Falha técnica')));

    await expectLater(
      repository.ouvirPagamentos(),
      emitsError(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível carregar os pagamentos. Tente novamente.',
        ),
      ),
    );
  });
}

Future<void> _registrarPagamento(PaymentRepositoryImpl repository) {
  return repository.registrarPagamento(
    data: '04/11/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Cidade',
    valor: 50.5,
    formaPagamento: 'Pix',
  );
}

Future<void> _atualizarPagamento(PaymentRepositoryImpl repository) {
  return repository.atualizarPagamento(
    id: 'pagamento-1',
    data: '04/11/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    valor: 50.5,
    formaPagamento: 'Pix',
  );
}
