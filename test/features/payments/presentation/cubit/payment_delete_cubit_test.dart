import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/payments/domain/repositories/payment_repository.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_delete_cubit.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_delete_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository paymentRepository;

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

  setUp(() {
    paymentRepository = MockPaymentRepository();
  });

  blocTest<PaymentDeleteCubit, PaymentDeleteState>(
    'admin exclui pagamento com sucesso',
    build: () {
      when(
        () => paymentRepository.excluirPagamento('pagamento-1'),
      ).thenAnswer((_) async {});
      return PaymentDeleteCubit(paymentRepository);
    },
    act: (cubit) => cubit.excluirPagamento(admin, 'pagamento-1'),
    expect: () => [PaymentDeleteLoading(), PaymentDeleteSuccess()],
    verify: (_) => verify(
      () => paymentRepository.excluirPagamento('pagamento-1'),
    ).called(1),
  );

  blocTest<PaymentDeleteCubit, PaymentDeleteState>(
    'motorista não pode excluir pagamento',
    build: () => PaymentDeleteCubit(paymentRepository),
    act: (cubit) => cubit.excluirPagamento(motorista, 'pagamento-1'),
    expect: () => [
      const PaymentDeleteError(
        'Somente administradores podem excluir pagamentos.',
      ),
    ],
    verify: (_) => verifyNever(() => paymentRepository.excluirPagamento(any())),
  );

  blocTest<PaymentDeleteCubit, PaymentDeleteState>(
    'exibe Failure devolvida pelo repository',
    build: () {
      when(
        () => paymentRepository.excluirPagamento('pagamento-1'),
      ).thenThrow(const ValidationFailure('Pagamento não encontrado.'));
      return PaymentDeleteCubit(paymentRepository);
    },
    act: (cubit) => cubit.excluirPagamento(admin, 'pagamento-1'),
    expect: () => [
      PaymentDeleteLoading(),
      const PaymentDeleteError('Pagamento não encontrado.'),
    ],
  );
}
