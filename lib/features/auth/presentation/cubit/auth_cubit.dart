import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(AuthInitial());

  final AuthRepository _authRepository;

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      await _authRepository.signInWithGoogle();
      emit(AuthInitial());
    } catch (e) {
      final message = e is Failure
          ? e.message
          : e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message));
    }
  }
}
