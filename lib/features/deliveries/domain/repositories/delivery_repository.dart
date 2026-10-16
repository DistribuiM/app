import '../entities/entrega.dart';

abstract class DeliveryRepository {
  Stream<List<Entrega>> ouvirEntregas({String? idMotorista});

  Stream<Entrega?> ouvirEntrega(String idEntrega);

  Stream<List<Entrega>> ouvirEntregasDoCliente(String idCliente);

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
  });
}
