import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';
import 'motorista_list_state.dart';

class MotoristaListCubit extends Cubit<MotoristaListState> {
  MotoristaListCubit(this._usuarioRepository)
    : super(MotoristaListInitial());

  final UsuarioRepository _usuarioRepository;

  Future<void> carregarMotoristas() async {
    emit(MotoristaListLoading());

    try {
      final motoristas = await _usuarioRepository.buscarMotoristas();
      emit(MotoristaListLoaded(motoristas));
    } catch (e) {
      if (e is Failure) {
        emit(MotoristaListError(e.message));
      } else {
        emit(
          const MotoristaListError('Erro inesperado. Tente novamente.'),
        );
      }
    }
  }
}
