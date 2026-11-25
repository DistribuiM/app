import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:app_distribuim/features/reports/domain/entities/dashboard_data.dart';
import 'package:app_distribuim/features/reports/domain/entities/report_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('agrega saldos atuais e pagamentos de hoje', () {
    final resumo = ReportSummary.fromData(
      DashboardData(
        clientes: [
          _cliente(id: 'cliente-1', saldoPendente: 120),
          _cliente(id: 'cliente-2', saldoPendente: -20),
        ],
        entregas: [
          _entrega(
            id: 'entrega-hoje',
            data: '25/11/2026',
            valorPago: 30,
            formaPagamento: 'Pix',
            quantidadeSacos: 10,
            entregue: true,
          ),
          _entrega(
            id: 'entrega-antiga',
            data: '24/11/2026',
            valorPago: 40,
            formaPagamento: 'Cartão',
            quantidadeSacos: 5,
            entregue: false,
          ),
        ],
        pagamentos: [
          Pagamento(
            id: 'pagamento-hoje',
            data: '25/11/2026',
            idMotorista: 'motorista-1',
            nomeMotorista: 'Ana',
            idCliente: 'cliente-1',
            nomeCliente: 'Cliente',
            cidadeCliente: 'Santos',
            valor: 50,
            formaPagamento: 'Dinheiro',
          ),
        ],
      ),
      hoje: DateTime(2026, 11, 25),
    );

    expect(resumo.totalPendente, 100);
    expect(resumo.totalPago, 120);
    expect(resumo.sacosEntregues, 10);
    expect(resumo.totalClientes, 2);
    expect(resumo.pendentesPorMotorista.single.valor, 120);
    expect(resumo.clientesComDividas.single.nome, 'Cliente');
    expect(resumo.resumoDeHoje.single.entregas, 1);
    expect(resumo.resumoDeHoje.single.dinheiro, 50);
    expect(resumo.resumoDeHoje.single.pix, 30);
    expect(resumo.resumoDeHoje.single.total, 80);
  });
}

Cliente _cliente({required String id, required double saldoPendente}) {
  return Cliente(
    id: id,
    nome: 'Cliente',
    telefone: '11999999999',
    endereco: Endereco(rua: 'Rua A', complemento: '', cidade: 'Santos'),
    saldoPendente: saldoPendente,
    idMotoristaResp: 'motorista-1',
    nomeMotoristaResp: 'Ana',
  );
}

Entrega _entrega({
  required String id,
  required String data,
  required double valorPago,
  required String formaPagamento,
  required int quantidadeSacos,
  required bool entregue,
}) {
  return Entrega(
    id: id,
    dataEntrega: data,
    idMotorista: 'motorista-1',
    nomeMotorista: 'Ana',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Santos',
    quantidadeSacos: quantidadeSacos,
    precoUnitario: 10,
    valorPago: valorPago,
    valorPendente: 0,
    formaPagamento: formaPagamento,
    pago: true,
    entregue: entregue,
    observacao: '',
  );
}
