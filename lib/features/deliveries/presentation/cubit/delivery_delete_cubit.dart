import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_delete_state.dart';

class DeliveryDeleteCubit extends Cubit<DeliveryDeleteState> {
  DeliveryDeleteCubit(this._deliveryRepository)
    : super(DeliveryDeleteInitial());

  final DeliveryRepository _deliveryRepository;

  Future<void> excluirEntrega(Usuario usuario, String id) async {
    if (isClosed || state is DeliveryDeleteLoading) return;
    if (!usuario.isAdmin) {
      emit(
        const DeliveryDeleteError(
          'Somente administradores podem excluir entregas.',
        ),
      );
      return;
    }

    emit(DeliveryDeleteLoading());
    try {
      await _deliveryRepository.excluirEntrega(id);
      if (!isClosed) emit(DeliveryDeleteSuccess());
    } on Failure catch (failure) {
      if (!isClosed) emit(DeliveryDeleteError(failure.message));
    } catch (_) {
      if (!isClosed) {
        emit(const DeliveryDeleteError('Erro inesperado. Tente novamente.'));
      }
    }
  }
}
