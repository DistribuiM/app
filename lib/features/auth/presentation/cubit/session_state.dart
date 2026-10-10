import 'package:equatable/equatable.dart';

import '../../domain/entities/usuario.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

class SessionLoading extends SessionState {}

class SessionUnauthenticated extends SessionState {}

class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.usuario);

  final Usuario usuario;

  @override
  List<Object> get props => [usuario];
}
