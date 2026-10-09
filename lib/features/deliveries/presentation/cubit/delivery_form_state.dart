import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../clients/domain/entities/cliente.dart';

sealed class DeliveryFormState extends Equatable {
  const DeliveryFormState();

  @override
  List<Object?> get props => [];
}

class DeliveryFormLoading extends DeliveryFormState {}

class DeliveryFormLoaded extends DeliveryFormState {
  const DeliveryFormLoaded({
    required this.motoristas,
    required this.clientes,
  });

  final List<Usuario> motoristas;
  final List<Cliente> clientes;

  @override
  List<Object?> get props => [motoristas, clientes];
}

class DeliveryFormSubmitting extends DeliveryFormState {
  const DeliveryFormSubmitting({
    required this.motoristas,
    required this.clientes,
  });

  final List<Usuario> motoristas;
  final List<Cliente> clientes;

  @override
  List<Object?> get props => [motoristas, clientes];
}

class DeliveryFormSuccess extends DeliveryFormState {}

class DeliveryFormError extends DeliveryFormState {
  const DeliveryFormError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
