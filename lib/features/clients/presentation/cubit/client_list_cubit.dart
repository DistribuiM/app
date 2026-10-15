import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/client_repository.dart';
import 'client_list_state.dart';

class ClientListCubit extends Cubit<ClientListState> {
  ClientListCubit(this._clientRepository) : super(ClientListInitial());

  final ClientRepository _clientRepository;
  StreamSubscription<List<Cliente>>? _subscription;

  void ouvirClientes(Usuario usuario) {
    _subscription?.cancel();
    emit(ClientListLoading());

    _subscription = _clientRepository
        .ouvirClientes(idMotorista: usuario.isAdmin ? null : usuario.id)
        .listen(
      (clientes) => emit(ClientListLoaded(clientes)),
      onError: (Object error) {
        if (error is Failure) {
          emit(ClientListError(error.message));
        } else {
          emit(const ClientListError('Erro inesperado. Tente novamente.'));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
