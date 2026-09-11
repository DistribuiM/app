class Entrega {
  final String id;
  final String dataEntrega;
  final String idMotorista;
  final String nomeMotorista;
  final String idCliente;
  final String nomeCliente;
  final String cidadeCliente;
  final int quantidadeSacos;
  final double precoUnitario;
  final double valorPago;
  final double valorPendente;
  final String formaPagamento;
  final bool pago;
  final bool entregue;
  final String observacao;

  Entrega({
    required this.id,
    required this.dataEntrega,
    required this.idMotorista,
    required this.nomeMotorista,
    required this.idCliente,
    required this.nomeCliente,
    required this.cidadeCliente,
    required this.quantidadeSacos,
    required this.precoUnitario,
    required this.valorPago,
    required this.valorPendente,
    required this.formaPagamento,
    required this.pago,
    required this.entregue,
    required this.observacao,
  });

  factory Entrega.fromMap(Map<String, dynamic> data, String id) {
    final mot = data['motorista'] ?? {};
    final cli = data['cliente'] ?? {};
    final fin = data['financeiro'] ?? {};
    final status = data['status'] ?? {};

    return Entrega(
      id: id,
      dataEntrega: data['dataEntrega'] ?? '',
      idMotorista: mot['id'] ?? '',
      nomeMotorista: mot['nome'] ?? '',
      idCliente: cli['id'] ?? '',
      nomeCliente: cli['nome'] ?? '',
      cidadeCliente: cli['cidade'] ?? '',
      quantidadeSacos: data['quantidadeSacos'] ?? 0,
      precoUnitario: (fin['precoUnitario'] ?? 0.0).toDouble(),
      valorPago: (fin['valorPago'] ?? 0.0).toDouble(),
      valorPendente: (fin['valorPendente'] ?? 0.0).toDouble(),
      formaPagamento: data['formaPagamento'] ?? 'Nenhum',
      pago: status['pago'] ?? false,
      entregue: status['entregue'] ?? true,
      observacao: data['observacao'] ?? '',
    );
  }
}