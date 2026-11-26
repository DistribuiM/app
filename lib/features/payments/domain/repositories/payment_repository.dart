import '../entities/pagamento.dart';

abstract class PaymentRepository {
  Stream<List<Pagamento>> ouvirPagamentos({String? idMotorista});

  Future<void> registrarPagamento({
    required String data,
    required String idMotorista,
    required String nomeMotorista,
    required String idCliente,
    required String nomeCliente,
    required String cidadeCliente,
    required double valor,
    required String formaPagamento,
  });
}
