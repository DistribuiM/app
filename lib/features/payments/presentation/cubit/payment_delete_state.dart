import 'package:equatable/equatable.dart';

sealed class PaymentDeleteState extends Equatable {
  const PaymentDeleteState();

  @override
  List<Object?> get props => [];
}

class PaymentDeleteInitial extends PaymentDeleteState {}

class PaymentDeleteLoading extends PaymentDeleteState {}

class PaymentDeleteSuccess extends PaymentDeleteState {}

class PaymentDeleteError extends PaymentDeleteState {
  const PaymentDeleteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
