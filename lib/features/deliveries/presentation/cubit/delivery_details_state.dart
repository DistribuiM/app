import 'package:equatable/equatable.dart';

import '../../domain/entities/entrega.dart';

sealed class DeliveryDetailsState extends Equatable {
  const DeliveryDetailsState();

  @override
  List<Object?> get props => [];
}

class DeliveryDetailsInitial extends DeliveryDetailsState {}

class DeliveryDetailsLoaded extends DeliveryDetailsState {
  const DeliveryDetailsLoaded(this.entrega);

  final Entrega entrega;

  @override
  List<Object?> get props => [entrega];
}

class DeliveryDetailsNotFound extends DeliveryDetailsState {}

class DeliveryDetailsError extends DeliveryDetailsState {
  const DeliveryDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
