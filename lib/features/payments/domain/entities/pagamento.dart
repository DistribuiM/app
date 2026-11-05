class Pagamento {
  final String id;
  final String data;
  final String idMotorista;
  final String nomeMotorista;
  final String idCliente;
  final String nomeCliente;
  final String cidadeCliente;
  final double valor;
  final String formaPagamento;

  Pagamento({
    required this.id,
    required this.data,
    required this.idMotorista,
    required this.nomeMotorista,
    required this.idCliente,
    required this.nomeCliente,
    required this.cidadeCliente,
    required this.valor,
    required this.formaPagamento,
  });

  factory Pagamento.fromMap(Map<String, dynamic> data, String id) {
    final motorista = data['motorista'] ?? {};
    final cliente = data['cliente'] ?? {};

    return Pagamento(
      id: id,
      data: data['data'] ?? '',
      idMotorista: motorista['id'] ?? '',
      nomeMotorista: motorista['nome'] ?? '',
      idCliente: cliente['id'] ?? '',
      nomeCliente: cliente['nome'] ?? '',
      cidadeCliente: cliente['cidade'] ?? '',
      valor: (data['valor'] ?? 0.0).toDouble(),
      formaPagamento: data['formaPagamento'] ?? '',
    );
  }
}
