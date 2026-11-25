import 'package:equatable/equatable.dart';

sealed class DeliveryDeleteState extends Equatable {
  const DeliveryDeleteState();

  @override
  List<Object?> get props => [];
}

class DeliveryDeleteInitial extends DeliveryDeleteState {}

class DeliveryDeleteLoading extends DeliveryDeleteState {}

class DeliveryDeleteSuccess extends DeliveryDeleteState {}

class DeliveryDeleteError extends DeliveryDeleteState {
  const DeliveryDeleteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
