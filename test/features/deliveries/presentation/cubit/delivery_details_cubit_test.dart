import 'dart:async';

import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_details_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_details_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

void main() {
  late MockDeliveryRepository deliveryRepository;
  late StreamController<Entrega?> controller;
  late StreamController<Entrega?> replacementController;
  final inicial = Entrega(
    id: 'entrega-1',
    dataEntrega: '2026-10-11',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Cidade',
    quantidadeSacos: 1,
    precoUnitario: 80,
    valorPago: 80,
    valorPendente: 0,
    formaPagamento: 'Dinheiro',
    pago: true,
    entregue: true,
    observacao: '',
  );
  final nova = Entrega(
    id: 'entrega-1',
    dataEntrega: '2026-10-12',
    idMotorista: 'motorista-2',
    nomeMotorista: 'Novo Motorista',
    idCliente: 'cliente-2',
    nomeCliente: 'Novo Cliente',
    cidadeCliente: 'Nova Cidade',
    quantidadeSacos: 2,
    precoUnitario: 90,
    valorPago: 0,
    valorPendente: 180,
    formaPagamento: 'Pix',
    pago: false,
    entregue: false,
    observacao: 'Atualizada',
  );

  setUp(() {
    deliveryRepository = MockDeliveryRepository();
    controller = StreamController<Entrega?>.broadcast();
    replacementController = StreamController<Entrega?>.broadcast();
  });

  tearDown(() async {
    if (!controller.isClosed) {
      await controller.close();
    }
    if (!replacementController.isClosed) {
      await replacementController.close();
    }
  });

  blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
    'emite a entrega inicial imediatamente',
    build: () {
      when(
        () => deliveryRepository.ouvirEntrega(inicial.id),
      ).thenAnswer((_) => controller.stream);
      return DeliveryDetailsCubit(deliveryRepository);
    },
    act: (cubit) => cubit.ouvirEntrega(inicial),
    expect: () => [DeliveryDetailsLoaded(inicial)],
  );

  blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
    'emite os dados atualizados recebidos pelo stream',
    build: () {
      when(
        () => deliveryRepository.ouvirEntrega(inicial.id),
      ).thenAnswer((_) => controller.stream);
      return DeliveryDetailsCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntrega(inicial);
      controller.add(nova);
      await controller.close();
    },
    expect: () => [DeliveryDetailsLoaded(inicial), DeliveryDetailsLoaded(nova)],
  );

  blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
    'emite NotFound quando o documento deixa de existir',
    build: () {
      when(
        () => deliveryRepository.ouvirEntrega(inicial.id),
      ).thenAnswer((_) => controller.stream);
      return DeliveryDetailsCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntrega(inicial);
      controller.add(null);
      await controller.close();
    },
    expect: () => [DeliveryDetailsLoaded(inicial), DeliveryDetailsNotFound()],
  );

  blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
    'emite a mensagem da Failure recebida pelo stream',
    build: () {
      when(
        () => deliveryRepository.ouvirEntrega(inicial.id),
      ).thenAnswer((_) => controller.stream);
      return DeliveryDetailsCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntrega(inicial);
      controller.addError(const ServerFailure('Falha no stream'));
      await controller.close();
    },
    expect: () => [
      DeliveryDetailsLoaded(inicial),
      const DeliveryDetailsError('Falha no stream'),
    ],
  );

  blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
    'emite mensagem genérica para erro comum no stream',
    build: () {
      when(
        () => deliveryRepository.ouvirEntrega(inicial.id),
      ).thenAnswer((_) => controller.stream);
      return DeliveryDetailsCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntrega(inicial);
      controller.addError(Exception('Falha'));
      await controller.close();
    },
    expect: () => [
      DeliveryDetailsLoaded(inicial),
      const DeliveryDetailsError('Erro inesperado. Tente novamente.'),
    ],
  );

  blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
    'nova chamada cancela a assinatura anterior',
    build: () {
      var calls = 0;
      when(() => deliveryRepository.ouvirEntrega(inicial.id)).thenAnswer((_) {
        calls++;
        return calls == 1 ? controller.stream : replacementController.stream;
      });
      return DeliveryDetailsCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntrega(inicial);
      expect(controller.hasListener, isTrue);

      cubit.ouvirEntrega(nova);
      expect(controller.hasListener, isFalse);
      expect(replacementController.hasListener, isTrue);
    },
    expect: () => [DeliveryDetailsLoaded(inicial), DeliveryDetailsLoaded(nova)],
  );

  test('close cancela a assinatura do stream', () async {
    when(
      () => deliveryRepository.ouvirEntrega(inicial.id),
    ).thenAnswer((_) => controller.stream);
    final cubit = DeliveryDetailsCubit(deliveryRepository);

    cubit.ouvirEntrega(inicial);
    expect(controller.hasListener, isTrue);

    await cubit.close();

    expect(controller.hasListener, isFalse);
  });
}
