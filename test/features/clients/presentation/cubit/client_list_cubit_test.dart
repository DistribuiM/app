import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:app_distribuim/features/clients/domain/repositories/client_repository.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_list_cubit.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  late MockClientRepository clientRepository;
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
  final clientes = [
    Cliente(
      id: 'cliente-1',
      nome: 'Cliente',
      telefone: '11999999999',
      endereco: Endereco(rua: 'Rua A', complemento: '', cidade: 'Cidade'),
      saldoPendente: 0,
      idMotoristaResp: 'motorista-1',
      nomeMotoristaResp: 'Motorista',
    ),
  ];

  setUp(() {
    clientRepository = MockClientRepository();
  });

  blocTest<ClientListCubit, ClientListState>(
    'emite loading e clientes carregados quando buscarClientes tem sucesso',
    build: () {
      when(
        () => clientRepository.buscarClientes(idMotorista: null),
      ).thenAnswer((_) async => clientes);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) => cubit.carregarClientes(admin),
    expect: () => [ClientListLoading(), ClientListLoaded(clientes)],
    verify: (_) => verify(
      () => clientRepository.buscarClientes(idMotorista: null),
    ).called(1),
  );

  blocTest<ClientListCubit, ClientListState>(
    'busca somente os clientes do motorista logado',
    build: () {
      when(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).thenAnswer((_) async => clientes);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) => cubit.carregarClientes(motorista),
    expect: () => [ClientListLoading(), ClientListLoaded(clientes)],
    verify: (_) => verify(
      () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
    ).called(1),
  );

  blocTest<ClientListCubit, ClientListState>(
    'emite loading e mensagem genérica quando buscarClientes lança Exception',
    build: () {
      when(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).thenThrow(Exception('Falha ao carregar clientes'));
      return ClientListCubit(clientRepository);
    },
    act: (cubit) => cubit.carregarClientes(motorista),
    expect: () => [
      ClientListLoading(),
      const ClientListError('Erro inesperado. Tente novamente.'),
    ],
    verify: (_) => verify(
      () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
    ).called(1),
  );

  blocTest<ClientListCubit, ClientListState>(
    'emite loading e a mensagem de ServerFailure',
    build: () {
      when(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).thenThrow(const ServerFailure('msg'));
      return ClientListCubit(clientRepository);
    },
    act: (cubit) => cubit.carregarClientes(motorista),
    expect: () => [
      ClientListLoading(),
      const ClientListError('msg'),
    ],
    verify: (_) => verify(
      () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
    ).called(1),
  );
}
