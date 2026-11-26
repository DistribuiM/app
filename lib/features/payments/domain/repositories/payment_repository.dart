import '../entities/pagamento.dart';

abstract class PaymentRepository {
  Stream<List<Pagamento>> ouvirPagamentos({String? idMotorista});

  Stream<List<Pagamento>> ouvirPagamentosDoCliente(String idCliente);

  Stream<Pagamento?> ouvirPagamento(String idPagamento);

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

  Future<void> atualizarPagamento({
    required String id,
    required String data,
    required String idMotorista,
    required String nomeMotorista,
    required double valor,
    required String formaPagamento,
  });

  Future<void> excluirPagamento(String id);
}
