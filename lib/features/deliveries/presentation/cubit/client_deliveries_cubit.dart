import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/delivery_repository.dart';
import 'delivery_list_state.dart';

class ClientDeliveriesCubit extends Cubit<DeliveryListState> {
  ClientDeliveriesCubit(this._deliveryRepository) : super(DeliveryListLoading());

  final DeliveryRepository _deliveryRepository;
  StreamSubscription? _subscription;

  void ouvirEntregasDoCliente(String idCliente) {
    _subscription?.cancel();
    _subscription = _deliveryRepository
        .ouvirEntregasDoCliente(idCliente)
        .listen(
          (entregas) => emit(DeliveryListLoaded(entregas)),
          onError: (Object error) => emit(DeliveryListError(error.toString())),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
