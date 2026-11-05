import '../entities/entrega.dart';
import 'dart:typed_data';

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
    Uint8List? comprovanteBytes,
  });

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
  });
  Future<Uint8List?> buscarComprovante(String idEntrega);
}
