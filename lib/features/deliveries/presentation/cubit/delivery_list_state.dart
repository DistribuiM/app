import 'package:equatable/equatable.dart';

import '../../domain/entities/entrega.dart';

sealed class DeliveryListState extends Equatable {
  const DeliveryListState();

  @override
  List<Object?> get props => [];
}

class DeliveryListLoading extends DeliveryListState {}

class DeliveryListLoaded extends DeliveryListState {
  const DeliveryListLoaded(this.entregas);

  final List<Entrega> entregas;

  @override
  List<Object?> get props => [entregas];
}

class DeliveryListError extends DeliveryListState {
  const DeliveryListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
