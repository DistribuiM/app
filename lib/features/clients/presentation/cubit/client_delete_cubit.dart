import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/repositories/client_repository.dart';
import 'client_delete_state.dart';

class ClientDeleteCubit extends Cubit<ClientDeleteState> {
  ClientDeleteCubit(this._clientRepository) : super(ClientDeleteInitial());

  final ClientRepository _clientRepository;

  Future<void> excluirCliente(Usuario usuario, String id) async {
    if (isClosed || state is ClientDeleteLoading) return;
    if (!usuario.isAdmin) {
      emit(
        const ClientDeleteError(
          'Somente administradores podem excluir clientes.',
        ),
      );
      return;
    }

    emit(ClientDeleteLoading());
    try {
      await _clientRepository.excluirCliente(id);
      if (!isClosed) emit(ClientDeleteSuccess());
    } on Failure catch (failure) {
      if (!isClosed) emit(ClientDeleteError(failure.message));
    } catch (_) {
      if (!isClosed) {
        emit(const ClientDeleteError('Erro inesperado. Tente novamente.'));
      }
    }
  }
}
