import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/pagamento.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._paymentRemoteDataSource);

  final PaymentRemoteDataSource _paymentRemoteDataSource;

  @override
  Stream<List<Pagamento>> ouvirPagamentos({String? idMotorista}) async* {
    try {
      await for (final pagamentos in _paymentRemoteDataSource.ouvirPagamentos(
        idMotorista: idMotorista,
      )) {
        yield pagamentos;
      }
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao carregar pagamentos: $e');
      throw ServerFailure(
        'Não foi possível carregar os pagamentos. Tente novamente.',
      );
    }
  }

  @override
  Stream<List<Pagamento>> ouvirPagamentosDoCliente(String idCliente) async* {
    try {
      await for (final pagamentos
          in _paymentRemoteDataSource.ouvirPagamentosDoCliente(idCliente)) {
        yield pagamentos;
      }
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao carregar pagamentos do cliente: $e');
      throw ServerFailure(
        'Não foi possível carregar os pagamentos do cliente. Tente novamente.',
      );
    }
  }

  @override
  Stream<Pagamento?> ouvirPagamento(String idPagamento) async* {
    try {
      await for (final pagamento in _paymentRemoteDataSource.ouvirPagamento(
        idPagamento,
      )) {
        yield pagamento;
      }
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao carregar pagamento: $e');
      throw ServerFailure(
        'Não foi possível carregar o pagamento. Tente novamente.',
      );
    }
  }

  @override
  Future<void> registrarPagamento({
    required String data,
    required String idMotorista,
    required String nomeMotorista,
    required String idCliente,
    required String nomeCliente,
    required String cidadeCliente,
    required double valor,
    required String formaPagamento,
  }) async {
    try {
      await _paymentRemoteDataSource.registrarPagamento(
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        valor: valor,
        formaPagamento: formaPagamento,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao registrar pagamento: $e');
      throw ServerFailure(
        'Não foi possível registrar o pagamento. Tente novamente.',
      );
    }
  }

  @override
  Future<void> atualizarPagamento({
    required String id,
    required String data,
    required String idMotorista,
    required String nomeMotorista,
    required double valor,
    required String formaPagamento,
  }) async {
    try {
      if (!valor.isFinite || valor <= 0) {
        throw const ValidationFailure(
          'Informe um valor de pagamento maior que zero.',
        );
      }
      await _paymentRemoteDataSource.atualizarPagamento(
        id: id,
        data: data,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        valor: valor,
        formaPagamento: formaPagamento,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao atualizar pagamento: $e');
      throw ServerFailure(
        'Não foi possível atualizar o pagamento. Tente novamente.',
      );
    }
  }

  @override
  Future<void> excluirPagamento(String id) async {
    try {
      await _paymentRemoteDataSource.excluirPagamento(id);
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao excluir pagamento: $e');
      throw ServerFailure(
        'Não foi possível excluir o pagamento. Tente novamente.',
      );
    }
  }
}
