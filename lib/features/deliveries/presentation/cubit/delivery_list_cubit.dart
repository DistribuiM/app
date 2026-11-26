import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../../clients/domain/repositories/client_repository.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_list_state.dart';

class DeliveryListCubit extends Cubit<DeliveryListState> {
  DeliveryListCubit(this._deliveryRepository, this._clientRepository)
    : super(DeliveryListLoading());

  final DeliveryRepository _deliveryRepository;
  final ClientRepository _clientRepository;
  StreamSubscription? _subscriptionEntregas;
  StreamSubscription? _subscriptionClientes;
  List<Entrega> _entregas = [];
  Map<String, Cliente> _clientes = {};

  void ouvirEntregas(Usuario usuario) {
    final idMotorista = usuario.isAdmin ? null : usuario.id;

    _subscriptionEntregas?.cancel();
    _subscriptionClientes?.cancel();

    _subscriptionClientes = _clientRepository
        .ouvirClientes(idMotorista: idMotorista)
        .listen(
          (clientes) {
            _clientes = {for (final cliente in clientes) cliente.id: cliente};
            _emitir();
          },
          // Se os clientes falharem, a lista continua com o nome salvo na entrega
          onError: (Object error) => debugPrint('Erro ao ouvir clientes: $error'),
        );

    _subscriptionEntregas = _deliveryRepository
        .ouvirEntregas(idMotorista: idMotorista)
        .listen(
          (entregas) {
            _entregas = entregas;
            _emitir();
          },
          onError: (Object error) => emit(DeliveryListError(error.toString())),
        );
  }

  void _emitir() {
    emit(DeliveryListLoaded(_entregas, clientes: _clientes));
  }

  @override
  Future<void> close() async {
    await _subscriptionEntregas?.cancel();
    await _subscriptionClientes?.cancel();
    await super.close();
  }
}