import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_list_state.dart';

class DeliveryListCubit extends Cubit<DeliveryListState> {
  DeliveryListCubit(this._deliveryRepository) : super(DeliveryListLoading());

  final DeliveryRepository _deliveryRepository;
  StreamSubscription? _subscription;

  void ouvirEntregas(Usuario usuario) {
    _subscription?.cancel();
    _subscription = _deliveryRepository
        .ouvirEntregas(idMotorista: usuario.isAdmin ? null : usuario.id)
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
