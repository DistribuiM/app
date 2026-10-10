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
        () => clientRepository.buscarClientes(),
      ).thenAnswer((_) async => clientes);
      return ClientListCubit(clientRepository);
    },
    act: (cubit) => cubit.carregarClientes(),
    expect: () => [ClientListLoading(), ClientListLoaded(clientes)],
    verify: (_) => verify(() => clientRepository.buscarClientes()).called(1),
  );

  blocTest<ClientListCubit, ClientListState>(
    'emite loading e erro quando buscarClientes falha',
    build: () {
      when(
        () => clientRepository.buscarClientes(),
      ).thenThrow(Exception('Falha ao carregar clientes'));
      return ClientListCubit(clientRepository);
    },
    act: (cubit) => cubit.carregarClientes(),
    expect: () => [
      ClientListLoading(),
      const ClientListError('Falha ao carregar clientes'),
    ],
    verify: (_) => verify(() => clientRepository.buscarClientes()).called(1),
  );
}
