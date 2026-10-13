import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/usuario.dart';

sealed class MotoristaListState extends Equatable {
  const MotoristaListState();

  @override
  List<Object?> get props => [];
}

class MotoristaListInitial extends MotoristaListState {}

class MotoristaListLoading extends MotoristaListState {}

class MotoristaListLoaded extends MotoristaListState {
  const MotoristaListLoaded(this.motoristas);

  final List<Usuario> motoristas;

  @override
  List<Object?> get props => [motoristas];
}

class MotoristaListError extends MotoristaListState {
  const MotoristaListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
