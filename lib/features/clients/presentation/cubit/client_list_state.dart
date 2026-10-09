import 'package:equatable/equatable.dart';

import '../../domain/entities/cliente.dart';

sealed class ClientListState extends Equatable {
  const ClientListState();

  @override
  List<Object?> get props => [];
}

class ClientListInitial extends ClientListState {}

class ClientListLoading extends ClientListState {}

class ClientListLoaded extends ClientListState {
  const ClientListLoaded(this.clientes);

  final List<Cliente> clientes;

  @override
  List<Object?> get props => [clientes];
}

class ClientListError extends ClientListState {
  const ClientListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
