import 'dart:async';

import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/deliveries/data/datasources/delivery_remote_data_source.dart';
import 'package:app_distribuim/features/deliveries/data/repositories/delivery_repository_impl.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/domain/repositories/delivery_repository.dart';
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

  group('ouvirEntregas', () {
    test('repassa idMotorista ao data source', () {
      final stream = Stream<List<Entrega>>.empty();
      when(
        () => dataSource.ouvirEntregas(idMotorista: idMotorista),
      ).thenAnswer((_) => stream);

      expect(repository.ouvirEntregas(idMotorista: idMotorista), same(stream));
      verify(
        () => dataSource.ouvirEntregas(idMotorista: idMotorista),
      ).called(1);
    });

    test('repassa null quando idMotorista é omitido', () {
      final stream = Stream<List<Entrega>>.empty();
      when(
        () => dataSource.ouvirEntregas(idMotorista: null),
      ).thenAnswer((_) => stream);

      expect(repository.ouvirEntregas(), same(stream));
      verify(() => dataSource.ouvirEntregas(idMotorista: null)).called(1);
    });
  });

  group('ouvirEntrega', () {
    const idEntrega = 'entrega-1';
    final entrega = Entrega(
      id: idEntrega,
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
    );

    test('repassa o id exato e encaminha dados e null', () async {
      final controller = StreamController<Entrega?>();
      when(
        () => dataSource.ouvirEntrega(idEntrega),
      ).thenAnswer((_) => controller.stream);

      final expectation = expectLater(
        repository.ouvirEntrega(idEntrega),
        emitsInOrder([same(entrega), isNull]),
      );
      controller
        ..add(entrega)
        ..add(null);
      await controller.close();
      await expectation;

      verify(() => dataSource.ouvirEntrega(idEntrega)).called(1);
    });

    test('repassa a mesma Failure emitida pelo stream', () async {
      const failure = ValidationFailure('Falha de validação');
      when(
        () => dataSource.ouvirEntrega(idEntrega),
      ).thenAnswer((_) => Stream<Entrega?>.error(failure));

      await expectLater(
        repository.ouvirEntrega(idEntrega),
        emitsError(same(failure)),
      );
    });

    test('converte erro comum do stream em ServerFailure', () async {
      when(
        () => dataSource.ouvirEntrega(idEntrega),
      ).thenAnswer((_) => Stream<Entrega?>.error(Exception('falha')));

      await expectLater(
        repository.ouvirEntrega(idEntrega),
        emitsError(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível carregar a entrega. Tente novamente.',
          ),
        ),
      );
    });

    test('converte erro síncrono do data source em ServerFailure', () async {
      when(
        () => dataSource.ouvirEntrega(idEntrega),
      ).thenThrow(Exception('falha'));

      await expectLater(
        repository.ouvirEntrega(idEntrega),
        emitsError(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível carregar a entrega. Tente novamente.',
          ),
        ),
      );
    });
  });

  group('atualizarEntrega', () {
    const id = 'entrega-2';
    const novaDataEntrega = '2026-10-15';
    const novoIdMotorista = 'motorista-2';
    const novoNomeMotorista = 'Novo Motorista';
    const novaQuantidade = 3;
    const novoPrecoUnitario = 90.0;
    const novoValorPago = 50.0;
    const novoValorPendente = 220.0;
    const novaFormaPagamento = 'Pix';
    const novoPago = false;
    const novaObservacao = 'Atualizada';

    test('relança a mesma Failure do data source', () async {
      const failure = ValidationFailure('msg');
      when(
        () => dataSource.atualizarEntrega(
          id: id,
          dataEntrega: novaDataEntrega,
          idMotorista: novoIdMotorista,
          nomeMotorista: novoNomeMotorista,
          quantidadeSacos: novaQuantidade,
          precoUnitario: novoPrecoUnitario,
          valorPago: novoValorPago,
          valorPendente: novoValorPendente,
          formaPagamento: novaFormaPagamento,
          pago: novoPago,
          observacao: novaObservacao,
        ),
      ).thenThrow(failure);

      await expectLater(
        _atualizarEntrega(
          repository,
          id: id,
          dataEntrega: novaDataEntrega,
          idMotorista: novoIdMotorista,
          nomeMotorista: novoNomeMotorista,
          quantidadeSacos: novaQuantidade,
          precoUnitario: novoPrecoUnitario,
          valorPago: novoValorPago,
          valorPendente: novoValorPendente,
          formaPagamento: novaFormaPagamento,
          pago: novoPago,
          observacao: novaObservacao,
        ),
        throwsA(same(failure)),
      );
    });

    test('converte Exception em ServerFailure', () async {
      when(
        () => dataSource.atualizarEntrega(
          id: id,
          dataEntrega: novaDataEntrega,
          idMotorista: novoIdMotorista,
          nomeMotorista: novoNomeMotorista,
          quantidadeSacos: novaQuantidade,
          precoUnitario: novoPrecoUnitario,
          valorPago: novoValorPago,
          valorPendente: novoValorPendente,
          formaPagamento: novaFormaPagamento,
          pago: novoPago,
          observacao: novaObservacao,
        ),
      ).thenThrow(Exception('falha'));

      await expectLater(
        _atualizarEntrega(
          repository,
          id: id,
          dataEntrega: novaDataEntrega,
          idMotorista: novoIdMotorista,
          nomeMotorista: novoNomeMotorista,
          quantidadeSacos: novaQuantidade,
          precoUnitario: novoPrecoUnitario,
          valorPago: novoValorPago,
          valorPendente: novoValorPendente,
          formaPagamento: novaFormaPagamento,
          pago: novoPago,
          observacao: novaObservacao,
        ),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Não foi possível atualizar a entrega. Tente novamente.',
          ),
        ),
      );
    });

    test('completa e repassa todos os valores exatos', () async {
      when(
        () => dataSource.atualizarEntrega(
          id: id,
          dataEntrega: novaDataEntrega,
          idMotorista: novoIdMotorista,
          nomeMotorista: novoNomeMotorista,
          quantidadeSacos: novaQuantidade,
          precoUnitario: novoPrecoUnitario,
          valorPago: novoValorPago,
          valorPendente: novoValorPendente,
          formaPagamento: novaFormaPagamento,
          pago: novoPago,
          observacao: novaObservacao,
        ),
      ).thenAnswer((_) async {});

      await expectLater(
        _atualizarEntrega(
          repository,
          id: id,
          dataEntrega: novaDataEntrega,
          idMotorista: novoIdMotorista,
          nomeMotorista: novoNomeMotorista,
          quantidadeSacos: novaQuantidade,
          precoUnitario: novoPrecoUnitario,
          valorPago: novoValorPago,
          valorPendente: novoValorPendente,
          formaPagamento: novaFormaPagamento,
          pago: novoPago,
          observacao: novaObservacao,
        ),
        completes,
      );

      verify(
        () => dataSource.atualizarEntrega(
          id: id,
          dataEntrega: novaDataEntrega,
          idMotorista: novoIdMotorista,
          nomeMotorista: novoNomeMotorista,
          quantidadeSacos: novaQuantidade,
          precoUnitario: novoPrecoUnitario,
          valorPago: novoValorPago,
          valorPendente: novoValorPendente,
          formaPagamento: novaFormaPagamento,
          pago: novoPago,
          observacao: novaObservacao,
        ),
      ).called(1);
    });
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

Future<void> _atualizarEntrega(
  DeliveryRepository repository, {
  required String id,
  required String dataEntrega,
  required String idMotorista,
  required String nomeMotorista,
  required int quantidadeSacos,
  required double precoUnitario,
  required double valorPago,
  required double valorPendente,
  required String formaPagamento,
  required bool pago,
  required String observacao,
}) {
  return repository.atualizarEntrega(
    id: id,
    dataEntrega: dataEntrega,
    idMotorista: idMotorista,
    nomeMotorista: nomeMotorista,
    quantidadeSacos: quantidadeSacos,
    precoUnitario: precoUnitario,
    valorPago: valorPago,
    valorPendente: valorPendente,
    formaPagamento: formaPagamento,
    pago: pago,
    observacao: observacao,
  );
}
