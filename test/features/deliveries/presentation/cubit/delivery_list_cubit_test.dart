import 'dart:async';

import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

void main() {
  late MockDeliveryRepository deliveryRepository;
  late StreamController<List<Entrega>> controller;
  final admin = Usuario(
    id: 'admin-1',
    nome: 'Admin',
    email: 'admin@example.com',
    cargo: CargoUsuario.admin,
  );
  final motorista = Usuario(
    id: 'motorista-1',
    nome: 'Motorista',
    email: 'motorista@example.com',
    cargo: CargoUsuario.motorista,
  );
  final entrega = Entrega(
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

  setUp(() {
    deliveryRepository = MockDeliveryRepository();
    controller = StreamController<List<Entrega>>();
  });

  tearDown(() async {
    if (!controller.isClosed) {
      await controller.close();
    }
  });

  blocTest<DeliveryListCubit, DeliveryListState>(
    'admin ouve todas as entregas e emite dados recebidos',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregas(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      return DeliveryListCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntregas(admin);
      controller.add([entrega]);
      await controller.close();
    },
    expect: () => [
      DeliveryListLoaded([entrega]),
    ],
    verify: (_) => verify(
      () => deliveryRepository.ouvirEntregas(idMotorista: null),
    ).called(1),
  );

  blocTest<DeliveryListCubit, DeliveryListState>(
    'motorista ouve somente suas entregas',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregas(idMotorista: 'motorista-1'),
      ).thenAnswer((_) => controller.stream);
      return DeliveryListCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntregas(motorista);
      controller.add([entrega]);
      await controller.close();
    },
    expect: () => [
      DeliveryListLoaded([entrega]),
    ],
    verify: (_) => verify(
      () => deliveryRepository.ouvirEntregas(idMotorista: 'motorista-1'),
    ).called(1),
  );

  blocTest<DeliveryListCubit, DeliveryListState>(
    'emite erro quando o stream falha',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregas(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      return DeliveryListCubit(deliveryRepository);
    },
    act: (cubit) async {
      cubit.ouvirEntregas(admin);
      controller.addError(Exception('Falha no stream'));
      await controller.close();
    },
    expect: () => [const DeliveryListError('Exception: Falha no stream')],
  );
}
