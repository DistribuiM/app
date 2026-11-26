import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/pagamento.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_details_state.dart';

class PaymentDetailsCubit extends Cubit<PaymentDetailsState> {
  PaymentDetailsCubit(this._paymentRepository)
    : super(PaymentDetailsInitial());

  final PaymentRepository _paymentRepository;
  StreamSubscription<Pagamento?>? _subscription;

  void ouvirPagamento(Pagamento inicial) {
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    emit(PaymentDetailsLoaded(inicial));

    try {
      _subscription = _paymentRepository.ouvirPagamento(inicial.id).listen(
        (pagamento) {
          if (pagamento == null) {
            emit(PaymentDetailsNotFound());
          } else {
            emit(PaymentDetailsLoaded(pagamento));
          }
        },
        onError: (Object error) {
          final message = error is Failure
              ? error.message
              : 'Erro inesperado. Tente novamente.';
          emit(PaymentDetailsError(message));
        },
      );
    } catch (error) {
      final message = error is Failure
          ? error.message
          : 'Erro inesperado. Tente novamente.';
      emit(PaymentDetailsError(message));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
