import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../payments/domain/entities/pagamento.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_list_state.dart';

class ClientDeliveriesCubit extends Cubit<DeliveryListState> {
  ClientDeliveriesCubit(this._deliveryRepository, this._paymentRepository)
    : super(DeliveryListLoading());

  final DeliveryRepository _deliveryRepository;
  final PaymentRepository _paymentRepository;
  StreamSubscription? _deliveriesSubscription;
  StreamSubscription? _paymentsSubscription;
  List<Entrega> _entregas = [];
  List<Pagamento> _pagamentos = [];
  bool _entregasCarregadas = false;
  bool _pagamentosCarregados = false;
  bool _errored = false;
  int _requestId = 0;

  void ouvirEntregasDoCliente(String idCliente) {
    final requestId = ++_requestId;
    _deliveriesSubscription?.cancel();
    _paymentsSubscription?.cancel();
    _entregas = [];
    _pagamentos = [];
    _entregasCarregadas = false;
    _pagamentosCarregados = false;
    _errored = false;
    if (state is! DeliveryListLoading) {
      emit(DeliveryListLoading());
    }

    _deliveriesSubscription = _deliveryRepository
        .ouvirEntregasDoCliente(idCliente)
        .listen((entregas) {
          if (requestId != _requestId || isClosed) return;
          _entregas = entregas;
          _entregasCarregadas = true;
          _emitLoadedIfReady();
        }, onError: (Object error) => _emitError(error, requestId));

    _paymentsSubscription = _paymentRepository
        .ouvirPagamentosDoCliente(idCliente)
        .listen((pagamentos) {
          if (requestId != _requestId || isClosed) return;
          _pagamentos = pagamentos;
          _pagamentosCarregados = true;
          _emitLoadedIfReady();
        }, onError: (Object error) => _emitError(error, requestId));
  }

  void _emitLoadedIfReady() {
    if (_errored || !_entregasCarregadas || !_pagamentosCarregados) return;
    emit(DeliveryListLoaded(_entregas, pagamentos: _pagamentos));
  }

  void _emitError(Object error, int requestId) {
    if (requestId != _requestId || isClosed) return;
    _errored = true;
    emit(
      DeliveryListError(
        error is Failure ? error.message : 'Erro inesperado. Tente novamente.',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _deliveriesSubscription?.cancel();
    await _paymentsSubscription?.cancel();
    await super.close();
  }
}
