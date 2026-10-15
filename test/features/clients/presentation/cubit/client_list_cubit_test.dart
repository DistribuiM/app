import 'dart:async';

import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:app_distribuim/features/clients/domain/repositories/client_repository.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_list_cubit.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  late MockClientRepository clientRepository;
  late StreamController<List<Cliente>> controller;
  late StreamController<List<Cliente>> replacementController;
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
  final cliente = Cliente(
    id: 'cliente-1',
    nome: 'Cliente',
    telefone: '11999999999',
    endereco: Endereco(rua: 'Rua A', complemento: '', cidade: 'Cidade'),
    saldoPendente: 0,
    idMotoristaResp: 'motorista-1',
    nomeMotoristaResp: 'Motorista',
  );

  setUp(() {
    clientRepository = MockClientRepository();
    controller = StreamController<List<Cliente>>.broadcast();
    replacementController = StreamController<List<Cliente>>.broadcast();
  });

  tearDown(() async {
    if (!controller.isClosed) {
      await controller.close();
    }
    if (!replacementController.isClosed) {
      await replacementController.close();
    }
  });

  blocTest<ClientListCubit, ClientListState>(
    'admin ouve todos os clientes',
    build: () {
      when(
        () => clientRepository.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) async {
      cubit.ouvirClientes(admin);
      controller.add([cliente]);
      await controller.close();
    },
    expect: () => [
      ClientListLoading(),
      ClientListLoaded([cliente]),
    ],
    verify: (_) => verify(
      () => clientRepository.ouvirClientes(idMotorista: null),
    ).called(1),
  );

  blocTest<ClientListCubit, ClientListState>(
    'motorista ouve somente seus clientes',
    build: () {
      when(
        () => clientRepository.ouvirClientes(idMotorista: 'motorista-1'),
      ).thenAnswer((_) => controller.stream);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) async {
      cubit.ouvirClientes(motorista);
      controller.add([cliente]);
      await controller.close();
    },
    expect: () => [
      ClientListLoading(),
      ClientListLoaded([cliente]),
    ],
    verify: (_) => verify(
      () => clientRepository.ouvirClientes(idMotorista: 'motorista-1'),
    ).called(1),
  );

  blocTest<ClientListCubit, ClientListState>(
    'emite cada nova lista recebida pelo stream',
    build: () {
      when(
        () => clientRepository.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) async {
      final lista1 = [cliente];
      final lista2 = <Cliente>[];
      cubit.ouvirClientes(admin);
      controller
        ..add(lista1)
        ..add(lista2);
      await controller.close();
    },
    expect: () => [
      ClientListLoading(),
      ClientListLoaded([cliente]),
      ClientListLoaded(<Cliente>[]),
    ],
  );

  blocTest<ClientListCubit, ClientListState>(
    'emite a mensagem de Failure recebido pelo stream',
    build: () {
      when(
        () => clientRepository.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) async {
      cubit.ouvirClientes(admin);
      controller.addError(const ServerFailure('Falha'));
      await controller.close();
    },
    expect: () => [ClientListLoading(), const ClientListError('Falha')],
  );

  blocTest<ClientListCubit, ClientListState>(
    'emite mensagem genérica para exceção comum no stream',
    build: () {
      when(
        () => clientRepository.ouvirClientes(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) async {
      cubit.ouvirClientes(admin);
      controller.addError(Exception('Falha ao carregar clientes'));
      await controller.close();
    },
    expect: () => [
      ClientListLoading(),
      const ClientListError('Erro inesperado. Tente novamente.'),
    ],
  );

  blocTest<ClientListCubit, ClientListState>(
    'permite ouvir um novo stream depois de um erro e cancela o anterior',
    build: () {
      var calls = 0;
      when(
        () => clientRepository.ouvirClientes(idMotorista: 'motorista-1'),
      ).thenAnswer((_) {
        calls++;
        return calls == 1 ? controller.stream : replacementController.stream;
      });
      return ClientListCubit(clientRepository);
    },
    act: (cubit) async {
      cubit.ouvirClientes(motorista);
      controller.addError(const ServerFailure('Falha'));
      await cubit.stream.firstWhere((state) => state is ClientListError);
      expect(controller.hasListener, isTrue);

      cubit.ouvirClientes(motorista);
      expect(controller.hasListener, isFalse);
      replacementController.add([cliente]);
      await replacementController.close();
    },
    expect: () => [
      ClientListLoading(),
      const ClientListError('Falha'),
      ClientListLoading(),
      ClientListLoaded([cliente]),
    ],
  );

  test('close cancela a assinatura do stream', () async {
    when(
      () => clientRepository.ouvirClientes(idMotorista: null),
    ).thenAnswer((_) => controller.stream);
    final cubit = ClientListCubit(clientRepository);

    cubit.ouvirClientes(admin);
    expect(controller.hasListener, isTrue);

    await cubit.close();

    expect(controller.hasListener, isFalse);
  });
}
