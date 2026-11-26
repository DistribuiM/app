import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_delete_state.dart';

class PaymentDeleteCubit extends Cubit<PaymentDeleteState> {
  PaymentDeleteCubit(this._paymentRepository) : super(PaymentDeleteInitial());

  final PaymentRepository _paymentRepository;

  Future<void> excluirPagamento(Usuario usuario, String id) async {
    if (isClosed || state is PaymentDeleteLoading) return;
    if (!usuario.isAdmin) {
      emit(
        const PaymentDeleteError(
          'Somente administradores podem excluir pagamentos.',
        ),
      );
      return;
    }

    emit(PaymentDeleteLoading());
    try {
      await _paymentRepository.excluirPagamento(id);
      if (!isClosed) emit(PaymentDeleteSuccess());
    } on Failure catch (failure) {
      if (!isClosed) emit(PaymentDeleteError(failure.message));
    } catch (_) {
      if (!isClosed) {
        emit(const PaymentDeleteError('Erro inesperado. Tente novamente.'));
      }
    }
  }
}
