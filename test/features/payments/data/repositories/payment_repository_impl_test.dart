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
