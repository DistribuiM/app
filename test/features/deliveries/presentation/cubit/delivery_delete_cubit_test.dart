import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_delete_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_delete_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

void main() {
  late MockDeliveryRepository repository;

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
    repository = MockDeliveryRepository();
  });

  blocTest<DeliveryDeleteCubit, DeliveryDeleteState>(
    'permite exclusão para admin',
    build: () {
      when(
        () => repository.excluirEntrega('entrega-1'),
      ).thenAnswer((_) async {});
      return DeliveryDeleteCubit(repository);
    },
    act: (cubit) => cubit.excluirEntrega(admin, 'entrega-1'),
    expect: () => [DeliveryDeleteLoading(), DeliveryDeleteSuccess()],
    verify: (_) =>
        verify(() => repository.excluirEntrega('entrega-1')).called(1),
  );

  blocTest<DeliveryDeleteCubit, DeliveryDeleteState>(
    'recusa exclusão para motorista sem chamar o repository',
    build: () => DeliveryDeleteCubit(repository),
    act: (cubit) => cubit.excluirEntrega(motorista, 'entrega-1'),
    expect: () => [
      const DeliveryDeleteError(
        'Somente administradores podem excluir entregas.',
      ),
    ],
    verify: (_) => verifyNever(() => repository.excluirEntrega(any())),
  );

  blocTest<DeliveryDeleteCubit, DeliveryDeleteState>(
    'exibe Failure.message quando o repository recusa a exclusão',
    build: () {
      when(
        () => repository.excluirEntrega('entrega-1'),
      ).thenThrow(const ValidationFailure('Entrega não encontrada.'));
      return DeliveryDeleteCubit(repository);
    },
    act: (cubit) => cubit.excluirEntrega(admin, 'entrega-1'),
    expect: () => [
      DeliveryDeleteLoading(),
      const DeliveryDeleteError('Entrega não encontrada.'),
    ],
  );
}
