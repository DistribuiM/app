import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/client_repository.dart';
import 'client_list_state.dart';

class ClientListCubit extends Cubit<ClientListState> {
  ClientListCubit(this._clientRepository) : super(ClientListInitial());

  final ClientRepository _clientRepository;

  Future<void> carregarClientes() async {
    emit(ClientListLoading());

    try {
      final clientes = await _clientRepository.buscarClientes();
      emit(ClientListLoaded(clientes));
    } catch (e) {
      if (e is Failure) {
        emit(ClientListError(e.message));
      } else {
        emit(const ClientListError('Erro inesperado. Tente novamente.'));
      }
    }
  }
}
