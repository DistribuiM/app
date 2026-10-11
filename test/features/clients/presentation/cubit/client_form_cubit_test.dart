import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/clients/domain/repositories/client_repository.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_form_cubit.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_form_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  late MockClientRepository clientRepository;

  setUp(() {
    clientRepository = MockClientRepository();
  });

  blocTest<ClientFormCubit, ClientFormState>(
    'emite Submitting e Success quando registrarCliente tem sucesso',
    build: () {
      when(
        () => clientRepository.registrarCliente(
          nome: 'Cliente',
          rua: 'Rua A',
          complemento: '',
          cidade: 'Cidade',
          telefone: '11999999999',
          idMotoristaResp: 'motorista-1',
          nomeMotoristaResp: 'Motorista',
        ),
      ).thenAnswer((_) async {});
      return ClientFormCubit(clientRepository);
    },
    act: (cubit) => cubit.registrarCliente(
      nome: 'Cliente',
      rua: 'Rua A',
      complemento: '',
      cidade: 'Cidade',
      telefone: '11999999999',
      idMotoristaResp: 'motorista-1',
      nomeMotoristaResp: 'Motorista',
    ),
    expect: () => [ClientFormSubmitting(), ClientFormSuccess()],
  );

  blocTest<ClientFormCubit, ClientFormState>(
    'emite Submitting e Error com a mensagem de ValidationFailure',
    build: () {
      when(
        () => clientRepository.registrarCliente(
          nome: 'Cliente',
          rua: 'Rua A',
          complemento: '',
          cidade: 'Cidade',
          telefone: '11999999999',
          idMotoristaResp: 'motorista-1',
          nomeMotoristaResp: 'Motorista',
        ),
      ).thenThrow(const ValidationFailure('msg'));
      return ClientFormCubit(clientRepository);
    },
    act: (cubit) => cubit.registrarCliente(
      nome: 'Cliente',
      rua: 'Rua A',
      complemento: '',
      cidade: 'Cidade',
      telefone: '11999999999',
      idMotoristaResp: 'motorista-1',
      nomeMotoristaResp: 'Motorista',
    ),
    expect: () => [
      ClientFormSubmitting(),
      const ClientFormError('msg'),
    ],
  );

  blocTest<ClientFormCubit, ClientFormState>(
    'emite mensagem genérica para uma Exception inesperada',
    build: () {
      when(
        () => clientRepository.registrarCliente(
          nome: 'Cliente',
          rua: 'Rua A',
          complemento: '',
          cidade: 'Cidade',
          telefone: '11999999999',
          idMotoristaResp: 'motorista-1',
          nomeMotoristaResp: 'Motorista',
        ),
      ).thenThrow(Exception('falha'));
      return ClientFormCubit(clientRepository);
    },
    act: (cubit) => cubit.registrarCliente(
      nome: 'Cliente',
      rua: 'Rua A',
      complemento: '',
      cidade: 'Cidade',
      telefone: '11999999999',
      idMotoristaResp: 'motorista-1',
      nomeMotoristaResp: 'Motorista',
    ),
    expect: () => [
      ClientFormSubmitting(),
      const ClientFormError('Erro inesperado. Tente novamente.'),
    ],
  );
}
