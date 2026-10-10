import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(AuthRepository authRepository) : super(SessionLoading()) {
    _sessionSubscription = authRepository.sessionChanges.listen((usuario) {
      emit(
        usuario == null
            ? SessionUnauthenticated()
            : SessionAuthenticated(usuario),
      );
    });
  }

  late final StreamSubscription<Usuario?> _sessionSubscription;

  @override
  Future<void> close() async {
    await _sessionSubscription.cancel();
    await super.close();
  }
}
