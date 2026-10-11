import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/deliveries/data/datasources/delivery_remote_data_source.dart';
import 'package:app_distribuim/features/deliveries/data/repositories/delivery_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryRemoteDataSource extends Mock
    implements DeliveryRemoteDataSource {}

void main() {
  late MockDeliveryRemoteDataSource dataSource;
  late DeliveryRepositoryImpl repository;

  const dataEntrega = '2026-10-11';
  const idMotorista = 'motorista-1';
  const nomeMotorista = 'Motorista';
  const idCliente = 'cliente-1';
  const nomeCliente = 'Cliente';
  const cidadeCliente = 'Cidade';
  const quantidadeSacos = 1;
  const precoUnitario = 80.0;
  const valorPago = 0.0;
  const valorPendente = 80.0;
  const formaPagamento = 'Dinheiro';
  const pago = false;
  const entregue = true;
  const observacao = '';

  setUp(() {
    dataSource = MockDeliveryRemoteDataSource();
    repository = DeliveryRepositoryImpl(dataSource);
  });

  test('relança a mesma Failure lançada pelo data source', () async {
    const failure = ValidationFailure('msg');
    when(
      () => dataSource.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      ),
    ).thenThrow(failure);

    await expectLater(
      repository.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      ),
      throwsA(same(failure)),
    );
  });

  test('converte Exception em ServerFailure com mensagem genérica', () async {
    when(
      () => dataSource.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      ),
    ).thenThrow(Exception('x'));

    await expectLater(
      repository.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      ),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Não foi possível registrar a entrega. Tente novamente.',
        ),
      ),
    );
  });

  test('completa sem erro quando o data source tem sucesso', () async {
    when(
      () => dataSource.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      ),
    ).thenAnswer((_) async {});

    await expectLater(
      repository.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      ),
      completes,
    );
  });
}
