import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pagamento.fromMap', () {
    test('mapeia todos os campos', () {
      final pagamento = Pagamento.fromMap({
        'data': '04/11/2026',
        'motorista': {'id': 'motorista-1', 'nome': 'Motorista'},
        'cliente': {'id': 'cliente-1', 'nome': 'Cliente', 'cidade': 'Cidade'},
        'valor': 50.5,
        'formaPagamento': 'Pix',
      }, 'pagamento-1');

      expect(pagamento.id, 'pagamento-1');
      expect(pagamento.data, '04/11/2026');
      expect(pagamento.idMotorista, 'motorista-1');
      expect(pagamento.nomeMotorista, 'Motorista');
      expect(pagamento.idCliente, 'cliente-1');
      expect(pagamento.nomeCliente, 'Cliente');
      expect(pagamento.cidadeCliente, 'Cidade');
      expect(pagamento.valor, 50.5);
      expect(pagamento.formaPagamento, 'Pix');
    });

    test('usa padrões quando o mapa está vazio', () {
      final pagamento = Pagamento.fromMap({}, 'pagamento-1');

      expect(pagamento.id, 'pagamento-1');
      expect(pagamento.data, '');
      expect(pagamento.idMotorista, '');
      expect(pagamento.nomeMotorista, '');
      expect(pagamento.idCliente, '');
      expect(pagamento.nomeCliente, '');
      expect(pagamento.cidadeCliente, '');
      expect(pagamento.valor, 0.0);
      expect(pagamento.formaPagamento, '');
    });

    test('converte valor inteiro do Firestore para double', () {
      final pagamento = Pagamento.fromMap({'valor': 50}, 'pagamento-1');

      expect(pagamento.valor, 50.0);
      expect(pagamento.valor, isA<double>());
    });
  });
}
