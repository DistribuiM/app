import '../../../clients/domain/entities/cliente.dart';
import 'dashboard_data.dart';

class ReportSummary {
  ReportSummary({
    required this.totalPendente,
    required this.totalPago,
    required this.sacosEntregues,
    required this.totalClientes,
    required this.pendentesPorMotorista,
    required this.resumoDeHoje,
    required this.clientesComDividas,
  });

  final double totalPendente;
  final double totalPago;
  final int sacosEntregues;
  final int totalClientes;
  final List<ValorPendenteMotorista> pendentesPorMotorista;
  final List<ResumoMotoristaHoje> resumoDeHoje;
  final List<ClienteComDivida> clientesComDividas;

  factory ReportSummary.fromData(DashboardData data, {DateTime? hoje}) {
    final dataAtual = hoje ?? DateTime.now();
    final pendentePorMotorista = <String, _PendenteAgrupado>{};
    for (final cliente in data.clientes) {
      if (cliente.saldoPendente <= 0) continue;

      final agrupado = pendentePorMotorista.putIfAbsent(
        cliente.idMotoristaResp,
        () => _PendenteAgrupado(cliente.nomeMotoristaResp),
      );
      agrupado.valor += cliente.saldoPendente;
    }

    final resumoPorMotorista = <String, _ResumoHojeAgrupado>{};
    for (final entrega in data.entregas) {
      if (!_ehHoje(entrega.dataEntrega, dataAtual)) continue;

      final agrupado = resumoPorMotorista.putIfAbsent(
        entrega.idMotorista,
        () => _ResumoHojeAgrupado(entrega.nomeMotorista),
      );
      agrupado.entregas++;
      agrupado.adicionarPagamento(entrega.formaPagamento, entrega.valorPago);
    }
    for (final pagamento in data.pagamentos) {
      if (!_ehHoje(pagamento.data, dataAtual)) continue;

      final agrupado = resumoPorMotorista.putIfAbsent(
        pagamento.idMotorista,
        () => _ResumoHojeAgrupado(pagamento.nomeMotorista),
      );
      agrupado.adicionarPagamento(pagamento.formaPagamento, pagamento.valor);
    }

    return ReportSummary(
      totalPendente: data.clientes.fold(
        0.0,
        (total, cliente) => total + cliente.saldoPendente,
      ),
      totalPago:
          data.entregas.fold(
            0.0,
            (total, entrega) => total + entrega.valorPago,
          ) +
          data.pagamentos.fold(
            0.0,
            (total, pagamento) => total + pagamento.valor,
          ),
      sacosEntregues: data.entregas
          .where((entrega) => entrega.entregue)
          .fold(0, (total, entrega) => total + entrega.quantidadeSacos),
      totalClientes: data.clientes.length,
      pendentesPorMotorista:
          pendentePorMotorista.entries
              .map(
                (entry) => ValorPendenteMotorista(
                  nomeMotorista: entry.value.nome,
                  valor: entry.value.valor,
                ),
              )
              .toList()
            ..sort((a, b) => a.nomeMotorista.compareTo(b.nomeMotorista)),
      resumoDeHoje:
          resumoPorMotorista.entries
              .map(
                (entry) => ResumoMotoristaHoje(
                  nomeMotorista: entry.value.nome,
                  entregas: entry.value.entregas,
                  dinheiro: entry.value.dinheiro,
                  pix: entry.value.pix,
                  cartao: entry.value.cartao,
                ),
              )
              .toList()
            ..sort((a, b) => a.nomeMotorista.compareTo(b.nomeMotorista)),
      clientesComDividas:
          data.clientes
              .where((cliente) => cliente.saldoPendente > 0)
              .map(ClienteComDivida.fromCliente)
              .toList()
            ..sort((a, b) => b.valor.compareTo(a.valor)),
    );
  }

  static bool _ehHoje(String valor, DateTime hoje) {
    final partes = valor.split('/');
    if (partes.length != 3) return false;
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);
    return dia == hoje.day && mes == hoje.month && ano == hoje.year;
  }
}

class ValorPendenteMotorista {
  const ValorPendenteMotorista({
    required this.nomeMotorista,
    required this.valor,
  });

  final String nomeMotorista;
  final double valor;
}

class ResumoMotoristaHoje {
  const ResumoMotoristaHoje({
    required this.nomeMotorista,
    required this.entregas,
    required this.dinheiro,
    required this.pix,
    required this.cartao,
  });

  final String nomeMotorista;
  final int entregas;
  final double dinheiro;
  final double pix;
  final double cartao;

  double get total => dinheiro + pix + cartao;
}

class ClienteComDivida {
  const ClienteComDivida({
    required this.nome,
    required this.cidade,
    required this.valor,
  });

  final String nome;
  final String cidade;
  final double valor;

  factory ClienteComDivida.fromCliente(Cliente cliente) {
    return ClienteComDivida(
      nome: cliente.nome,
      cidade: cliente.endereco.cidade,
      valor: cliente.saldoPendente,
    );
  }
}

class _PendenteAgrupado {
  _PendenteAgrupado(this.nome);

  final String nome;
  double valor = 0;
}

class _ResumoHojeAgrupado {
  _ResumoHojeAgrupado(this.nome);

  final String nome;
  int entregas = 0;
  double dinheiro = 0;
  double pix = 0;
  double cartao = 0;

  void adicionarPagamento(String forma, double valor) {
    switch (forma.trim().toLowerCase()) {
      case 'dinheiro':
        dinheiro += valor;
      case 'pix':
        pix += valor;
      case 'cartão':
      case 'cartao':
        cartao += valor;
    }
  }
}
