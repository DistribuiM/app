import 'dart:async';
import 'dart:typed_data';

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
  Uint8List? _comprovante;
  String? _comprovanteErro;

  void ouvirEntrega(Entrega inicial) {
    _subscription?.cancel();
    emit(DeliveryDetailsLoaded(inicial));
    if (inicial.temComprovante) {
      carregarComprovante(inicial.id);
    }
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
    comprovanteBytes: _comprovante,
    comprovanteErro: _comprovanteErro,
  );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}