import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/filtros_entrega.dart';
import 'package:app_distribuim/features/deliveries/presentation/widgets/delivery_filters_sheet.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final entregas = [
    Entrega(
      id: 'entrega-1',
      dataEntrega: '25/11/2026',
      idMotorista: 'motorista-1',
      nomeMotorista: 'Motorista',
      idCliente: 'cliente-1',
      nomeCliente: 'Cliente',
      cidadeCliente: 'Santos',
      quantidadeSacos: 2,
      precoUnitario: 80,
      valorPago: 100,
      valorPendente: 60,
      formaPagamento: 'Pix',
      pago: false,
      entregue: true,
      observacao: '',
    ),
  ];
  final pagamentos = [
    Pagamento(
      id: 'pagamento-1',
      data: '26/11/2026',
      idMotorista: 'motorista-2',
      nomeMotorista: 'Outro Motorista',
      idCliente: 'cliente-2',
      nomeCliente: 'Outro Cliente',
      cidadeCliente: 'Guarujá',
      valor: 35,
      formaPagamento: 'Dinheiro',
    ),
  ];

  testWidgets('apresenta todos os critérios de filtro solicitados', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => DeliveryFiltersSheet(
                    entregas: entregas,
                    pagamentos: pagamentos,
                    filtrosIniciais: const FiltrosEntrega(),
                    onApply: (_) {},
                  ),
                ),
                child: const Text('Abrir filtros'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir filtros'));
    await tester.pumpAndSettle();

    for (final texto in [
      'Filtrar entregas',
      'Data inicial',
      'Data final',
      'Motorista',
      'Cliente',
      'Forma de pagamento',
      'Tipo de formulário',
      'Cidade da entrega',
      'Quantidade de sacos',
      'Valor pago',
      'Limpar filtros',
      'Aplicar',
    ]) {
      await tester.ensureVisible(find.text(texto));
      expect(find.text(texto), findsWidgets);
    }

    final tipoFormulario = find.byType(DropdownMenu<String>).at(3);
    await tester.ensureVisible(tipoFormulario);
    await tester.tap(tipoFormulario);
    await tester.pumpAndSettle();
    expect(find.text('Pagamento'), findsOneWidget);

    final formaPagamento = find.byType(DropdownMenu<String>).at(2);
    await tester.tap(formaPagamento);
    await tester.pumpAndSettle();
    expect(find.text('Dinheiro'), findsOneWidget);

    final cidade = find.byType(DropdownMenu<String>).at(4);
    await tester.tap(cidade);
    await tester.pumpAndSettle();
    expect(find.text('Guarujá'), findsOneWidget);
  });
}
