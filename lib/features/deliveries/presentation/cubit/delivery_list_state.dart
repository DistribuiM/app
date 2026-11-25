import 'package:equatable/equatable.dart';

import '../../../clients/domain/entities/cliente.dart';
import '../../domain/entities/entrega.dart';

sealed class DeliveryListState extends Equatable {
  const DeliveryListState();

  @override
  List<Object?> get props => [];
}

class DeliveryListLoading extends DeliveryListState {}

class DeliveryListLoaded extends DeliveryListState {
  const DeliveryListLoaded(this.entregas, {this.clientes = const {}});

  final List<Entrega> entregas;
  final Map<String, Cliente> clientes;

  @override
  List<Object?> get props => [entregas, clientes];
}

class DeliveryListError extends DeliveryListState {
  const DeliveryListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}