import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._paymentRemoteDataSource);

  final PaymentRemoteDataSource _paymentRemoteDataSource;

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
}
