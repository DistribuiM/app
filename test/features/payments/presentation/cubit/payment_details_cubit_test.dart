import 'dart:async';

import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:app_distribuim/features/payments/domain/repositories/payment_repository.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_details_cubit.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_details_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository paymentRepository;
  late StreamController<Pagamento?> controller;

  final pagamento = Pagamento(
    id: 'pagamento-1',
    data: '25/11/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Santos',
    valor: 35,
    formaPagamento: 'Pix',
  );
  final pagamentoAtualizado = Pagamento(
    id: 'pagamento-1',
    data: '26/11/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Santos',
    valor: 50,
    formaPagamento: 'Dinheiro',
  );

  setUp(() {
    paymentRepository = MockPaymentRepository();
    controller = StreamController<Pagamento?>();
  });

  tearDown(() async {
    if (!controller.isClosed) {
      await controller.close();
    }
  });

  blocTest<PaymentDetailsCubit, PaymentDetailsState>(
    'emite o pagamento recebido inicialmente',
    build: () {
      when(
        () => paymentRepository.ouvirPagamento(pagamento.id),
      ).thenAnswer((_) => controller.stream);
      return PaymentDetailsCubit(paymentRepository);
    },
    act: (cubit) => cubit.ouvirPagamento(pagamento),
    expect: () => [PaymentDetailsLoaded(pagamento)],
    verify: (_) =>
        verify(() => paymentRepository.ouvirPagamento(pagamento.id)).called(1),
  );

  blocTest<PaymentDetailsCubit, PaymentDetailsState>(
    'atualiza os dados e informa quando o pagamento deixa de existir',
    build: () {
      when(
        () => paymentRepository.ouvirPagamento(pagamento.id),
      ).thenAnswer((_) => controller.stream);
      return PaymentDetailsCubit(paymentRepository);
    },
    act: (cubit) async {
      cubit.ouvirPagamento(pagamento);
      controller
        ..add(pagamentoAtualizado)
        ..add(null);
      await controller.close();
    },
    expect: () => [
      PaymentDetailsLoaded(pagamento),
      PaymentDetailsLoaded(pagamentoAtualizado),
      PaymentDetailsNotFound(),
    ],
  );

  blocTest<PaymentDetailsCubit, PaymentDetailsState>(
    'exibe a mensagem de Failure recebida do repository',
    build: () {
      when(
        () => paymentRepository.ouvirPagamento(pagamento.id),
      ).thenAnswer((_) => controller.stream);
      return PaymentDetailsCubit(paymentRepository);
    },
    act: (cubit) async {
      cubit.ouvirPagamento(pagamento);
      controller.addError(const ServerFailure('Falha ao carregar pagamento'));
      await controller.close();
    },
    expect: () => [
      PaymentDetailsLoaded(pagamento),
      const PaymentDetailsError('Falha ao carregar pagamento'),
    ],
  );
}
