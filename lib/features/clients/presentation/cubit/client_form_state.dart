import 'package:equatable/equatable.dart';

sealed class ClientFormState extends Equatable {
  const ClientFormState();

  @override
  List<Object?> get props => [];
}

class ClientFormInitial extends ClientFormState {}

class ClientFormSubmitting extends ClientFormState {}

class ClientFormSuccess extends ClientFormState {}

class ClientFormError extends ClientFormState {
  const ClientFormError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
