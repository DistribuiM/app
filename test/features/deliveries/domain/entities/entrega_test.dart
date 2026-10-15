import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:flutter_test/flutter_test.dart';

Entrega _makeEntrega({
  required int quantidadeSacos,
  required double precoUnitario,
}) {
  return Entrega(
    id: 'entrega-1',
    dataEntrega: '27/09/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Pedro Dias',
    idCliente: 'cliente-1',
    nomeCliente: 'Joao',
    cidadeCliente: 'Cubatão',
    quantidadeSacos: quantidadeSacos,
    precoUnitario: precoUnitario,
    valorPago: 0,
    valorPendente: quantidadeSacos * precoUnitario,
    formaPagamento: 'Pix',
    pago: false,
    entregue: true,
    observacao: '',
  );
}

void main() {
  test('valorTotal é quantidade de sacos vezes preço unitário', () {
    final entrega = _makeEntrega(quantidadeSacos: 3, precoUnitario: 90);

    expect(entrega.valorTotal, 270);
  });

  test('valorTotal é zero quando não há sacos', () {
    final entrega = _makeEntrega(quantidadeSacos: 0, precoUnitario: 90);

    expect(entrega.valorTotal, 0);
  });
}
