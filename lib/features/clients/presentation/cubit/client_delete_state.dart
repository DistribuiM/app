import 'package:equatable/equatable.dart';

sealed class ClientDeleteState extends Equatable {
  const ClientDeleteState();

  @override
  List<Object?> get props => [];
}

class ClientDeleteInitial extends ClientDeleteState {}

class ClientDeleteLoading extends ClientDeleteState {}

class ClientDeleteSuccess extends ClientDeleteState {}

class ClientDeleteError extends ClientDeleteState {
  const ClientDeleteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
