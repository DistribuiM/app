import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/client_repository.dart';
import 'client_form_state.dart';

class ClientFormCubit extends Cubit<ClientFormState> {
  ClientFormCubit(this._clientRepository) : super(ClientFormInitial());

  final ClientRepository _clientRepository;

  Future<void> registrarCliente({
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    required String idMotoristaResp,
    required String nomeMotoristaResp,
  }) async {
    emit(ClientFormSubmitting());

    try {
      await _clientRepository.registrarCliente(
        nome: nome,
        rua: rua,
        complemento: complemento,
        cidade: cidade,
        telefone: telefone,
        idMotoristaResp: idMotoristaResp,
        nomeMotoristaResp: nomeMotoristaResp,
      );
      emit(ClientFormSuccess());
    } catch (error) {
      emit(ClientFormError(error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
