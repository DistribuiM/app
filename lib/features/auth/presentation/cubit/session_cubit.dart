import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(AuthRepository authRepository)
      : _authRepository = authRepository,
        super(SessionLoading()) {
    _sessionSubscription = _authRepository.sessionChanges.listen(
      (usuario) {
        emit(
          usuario == null
              ? SessionUnauthenticated()
              : SessionAuthenticated(usuario),
        );
      },
      onError: (Object error, StackTrace stackTrace) async {
        debugPrint('Erro ao verificar a sessão: $error');
        if (!isClosed) {
          emit(SessionUnauthenticated());
        }
        try {
          await _authRepository.signOut();
        } catch (_) {}
      },
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<Usuario?> _sessionSubscription;

  @override
  Future<void> close() async {
    await _sessionSubscription.cancel();
    await super.close();
  }
}
