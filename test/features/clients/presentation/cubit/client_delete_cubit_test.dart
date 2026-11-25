import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/clients/domain/repositories/client_repository.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_delete_cubit.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_delete_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  late MockClientRepository repository;

  final admin = Usuario(
    id: 'admin@example.com',
    nome: 'Admin',
    email: 'admin@example.com',
    cargo: CargoUsuario.admin,
  );
  final motorista = Usuario(
    id: 'motorista@example.com',
    nome: 'Motorista',
    email: 'motorista@example.com',
    cargo: CargoUsuario.motorista,
  );

  setUp(() {
    repository = MockClientRepository();
  });

  blocTest<ClientDeleteCubit, ClientDeleteState>(
    'permite exclusão para admin',
    build: () {
      when(
        () => repository.excluirCliente('cliente-1'),
      ).thenAnswer((_) async {});
      return ClientDeleteCubit(repository);
    },
    act: (cubit) => cubit.excluirCliente(admin, 'cliente-1'),
    expect: () => [ClientDeleteLoading(), ClientDeleteSuccess()],
    verify: (_) =>
        verify(() => repository.excluirCliente('cliente-1')).called(1),
  );

  blocTest<ClientDeleteCubit, ClientDeleteState>(
    'recusa exclusão para motorista sem chamar o repository',
    build: () => ClientDeleteCubit(repository),
    act: (cubit) => cubit.excluirCliente(motorista, 'cliente-1'),
    expect: () => [
      const ClientDeleteError(
        'Somente administradores podem excluir clientes.',
      ),
    ],
    verify: (_) => verifyNever(() => repository.excluirCliente(any())),
  );

  blocTest<ClientDeleteCubit, ClientDeleteState>(
    'exibe Failure.message quando o repository recusa a exclusão',
    build: () {
      when(
        () => repository.excluirCliente('cliente-1'),
      ).thenThrow(const ValidationFailure('Cliente possui histórico.'));
      return ClientDeleteCubit(repository);
    },
    act: (cubit) => cubit.excluirCliente(admin, 'cliente-1'),
    expect: () => [
      ClientDeleteLoading(),
      const ClientDeleteError('Cliente possui histórico.'),
    ],
  );
}
