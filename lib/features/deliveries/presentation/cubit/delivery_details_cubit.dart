import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../../clients/domain/repositories/client_repository.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_details_state.dart';

class DeliveryDetailsCubit extends Cubit<DeliveryDetailsState> {
  DeliveryDetailsCubit(this._deliveryRepository, this._clientRepository)
    : super(DeliveryDetailsInitial());

  final DeliveryRepository _deliveryRepository;
  final ClientRepository _clientRepository;
  StreamSubscription<Entrega?>? _subscription;
  Uint8List? _comprovante;
  String? _comprovanteErro;
  Cliente? _cliente;

  void ouvirEntrega(Entrega inicial) {
    _subscription?.cancel();
    emit(_carregado(inicial));
    if (inicial.temComprovante) {
      carregarComprovante(inicial.id);
    }
    _carregarCliente(inicial.idCliente);

    _subscription = _deliveryRepository
        .ouvirEntrega(inicial.id)
        .listen(
          (entrega) {
            if (entrega == null) {
              emit(DeliveryDetailsNotFound());
            } else {
              emit(_carregado(entrega));
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

  Future<void> _carregarCliente(String idCliente) async {
    try {
      _cliente = await _clientRepository.buscarCliente(idCliente);
    } catch (erro) {
      // Sem o cliente atual, a tela usa o nome e a cidade salvos na entrega
      debugPrint('Erro ao buscar cliente da entrega: $erro');
    }
    final atual = state;
    if (!isClosed && atual is DeliveryDetailsLoaded) {
      emit(_carregado(atual.entrega));
    }
  }

  Future<void> carregarComprovante(String idEntrega) async {
    try {
      _comprovante = await _deliveryRepository.buscarComprovante(idEntrega);
      _comprovanteErro = _comprovante == null
          ? 'Comprovante não encontrado.'
          : null;
    } on Failure catch (e) {
      _comprovanteErro = e.message;
    } catch (_) {
      _comprovanteErro = 'Não foi possível carregar o comprovante.';
    }
    final atual = state;
    if (!isClosed && atual is DeliveryDetailsLoaded) {
      emit(_carregado(atual.entrega));
    }
  }

  DeliveryDetailsLoaded _carregado(Entrega entrega) => DeliveryDetailsLoaded(
    entrega,
    cliente: _cliente,
    comprovanteBytes: _comprovante,
    comprovanteErro: _comprovanteErro,
  );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}