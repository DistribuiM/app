import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_remote_data_source.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._deliveryRemoteDataSource);

  final DeliveryRemoteDataSource _deliveryRemoteDataSource;

  @override
  Stream<List<Entrega>> ouvirEntregas({String? idMotorista}) {
    return _deliveryRemoteDataSource.ouvirEntregas(
      idMotorista: idMotorista,
    );
  }

  @override
  Stream<Entrega?> ouvirEntrega(String idEntrega) async* {
    try {
      await for (final entrega in _deliveryRemoteDataSource.ouvirEntrega(
        idEntrega,
      )) {
        yield entrega;
      }
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao carregar entrega: $e');
      throw ServerFailure(
        'Não foi possível carregar a entrega. Tente novamente.',
      );
    }
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
    Uint8List? comprovanteBytes,
  }) async {
    if (comprovanteBytes != null && comprovanteBytes.length > 900 * 1024) {
      throw const ValidationFailure(
        'O comprovante é muito grande. Escolha uma imagem menor.',
      );
    }
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
        comprovanteBytes: comprovanteBytes,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao registrar entrega: $e');
      throw ServerFailure('Não foi possível registrar a entrega. Tente novamente.');
    }
  }

  @override
  Future<void> atualizarEntrega({
    required String id,
    required String dataEntrega,
    required String idMotorista,
    required String nomeMotorista,
    required int quantidadeSacos,
    required double precoUnitario,
    required double valorPago,
    required double valorPendente,
    required String formaPagamento,
    required bool pago,
    required String observacao,
  }) async {
    try {
      await _deliveryRemoteDataSource.atualizarEntrega(
        id: id,
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        observacao: observacao,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao atualizar entrega: $e');
      throw ServerFailure(
        'Não foi possível atualizar a entrega. Tente novamente.',
      );
    }
  }
  @override
  Future<Uint8List?> buscarComprovante(String idEntrega) async {
    try {
      return await _deliveryRemoteDataSource.buscarComprovante(idEntrega);
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao buscar comprovante: $e');
      throw ServerFailure('Não foi possível carregar o comprovante.');
    }
  }
}
