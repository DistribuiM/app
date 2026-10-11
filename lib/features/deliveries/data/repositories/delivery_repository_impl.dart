import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_remote_data_source.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._deliveryRemoteDataSource);

  final DeliveryRemoteDataSource _deliveryRemoteDataSource;

  @override
  Stream<List<Entrega>> ouvirEntregas() {
    return _deliveryRemoteDataSource.ouvirEntregas();
  }

  @override
  Stream<List<Entrega>> ouvirEntregasDoCliente(String idCliente) {
    return _deliveryRemoteDataSource.ouvirEntregasDoCliente(idCliente);
  }

  @override
  Future<void> registrarEntrega({
    required String dataEntrega,
    required String idMotorista,
    required String nomeMotorista,
    required String idCliente,
    required String nomeCliente,
    required String cidadeCliente,
    required int quantidadeSacos,
    required double precoUnitario,
    required double valorPago,
    required double valorPendente,
    required String formaPagamento,
    required bool pago,
    required bool entregue,
    required String observacao,
  }) async {
    try {
      await _deliveryRemoteDataSource.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao registrar entrega: $e');
      throw ServerFailure('Não foi possível registrar a entrega. Tente novamente.');
    }
  }
}
