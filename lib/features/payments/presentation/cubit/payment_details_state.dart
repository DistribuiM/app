import 'package:equatable/equatable.dart';

import '../../domain/entities/pagamento.dart';

sealed class PaymentDetailsState extends Equatable {
  const PaymentDetailsState();

  @override
  List<Object?> get props => [];
}

class PaymentDetailsInitial extends PaymentDetailsState {}

class PaymentDetailsLoaded extends PaymentDetailsState {
  const PaymentDetailsLoaded(this.pagamento);

  final Pagamento pagamento;

  @override
  List<Object?> get props => [pagamento];
}

class PaymentDetailsNotFound extends PaymentDetailsState {}

class PaymentDetailsError extends PaymentDetailsState {
  const PaymentDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
