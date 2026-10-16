import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_details_state.dart';

class DeliveryDetailsCubit extends Cubit<DeliveryDetailsState> {
  DeliveryDetailsCubit(this._deliveryRepository)
    : super(DeliveryDetailsInitial());

  final DeliveryRepository _deliveryRepository;
  StreamSubscription<Entrega?>? _subscription;

  void ouvirEntrega(Entrega inicial) {
    _subscription?.cancel();
    emit(DeliveryDetailsLoaded(inicial));
    _subscription = _deliveryRepository
        .ouvirEntrega(inicial.id)
        .listen(
          (entrega) {
            if (entrega == null) {
              emit(DeliveryDetailsNotFound());
            } else {
              emit(DeliveryDetailsLoaded(entrega));
            }
          },
          onError: (Object error) {
            if (error is Failure) {
              emit(DeliveryDetailsError(error.message));
            } else {
              emit(
                const DeliveryDetailsError('Erro inesperado. Tente novamente.'),
              );
            }
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
