import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/presentation/pages/delivery_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Entrega _makeEntrega({
  bool pago = false,
  bool entregue = true,
  String observacao = '',
}) {
  return Entrega(
    id: 'entrega-1',
    dataEntrega: '27/09/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Pedro Dias',
    idCliente: 'cliente-1',
    nomeCliente: 'Joao',
    cidadeCliente: 'Cubatão',
    quantidadeSacos: 3,
    precoUnitario: 90,
    valorPago: 100,
    valorPendente: 170,
    formaPagamento: 'Pix',
    pago: pago,
    entregue: entregue,
    observacao: observacao,
  );
}

Widget _buildPage(Entrega entrega) {
  return MaterialApp(home: EntregaPage(entrega: entrega));
}

void main() {
  testWidgets('exibe os dados da entrega e do pagamento', (tester) async {
    await tester.pumpWidget(_buildPage(_makeEntrega()));

    for (final texto in [
      'Detalhe da Entrega',
      'Joao',
      'Cubatão',
      '27/09/2026',
      'Pedro Dias',
      '3',
      'R\$90.00',
      'R\$270.00',
      'R\$100.00',
      'R\$170.00',
      'Pix',
      'Pendente',
      'Entregue',
    ]) {
      expect(find.text(texto), findsOneWidget);
    }
    expect(find.text('Observação'), findsNothing);
  });

  testWidgets('exibe o estado pago e não entregue', (tester) async {
    await tester.pumpWidget(
      _buildPage(_makeEntrega(pago: true, entregue: false)),
    );

    expect(find.text('Pago'), findsOneWidget);
    expect(find.text('Não entregue'), findsOneWidget);
  });

  testWidgets('omite observação vazia ou só com espaços', (tester) async {
    await tester.pumpWidget(_buildPage(_makeEntrega(observacao: '   \n ')));

    expect(find.text('Observação'), findsNothing);
  });

  testWidgets('exibe observação preenchida', (tester) async {
    await tester.pumpWidget(
      _buildPage(_makeEntrega(observacao: 'Entregar no portão lateral')),
    );

    await tester.scrollUntilVisible(
      find.text('Entregar no portão lateral'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Observação'), findsOneWidget);
    expect(find.text('Entregar no portão lateral'), findsOneWidget);
  });
}
