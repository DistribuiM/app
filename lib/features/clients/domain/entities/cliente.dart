import 'endereco.dart';

class Cliente {
  final String id;
  final String nome;
  final String telefone;
  final Endereco endereco;
  final double saldoPendente;
  final String idMotoristaResp;
  final String nomeMotoristaResp;
  final bool permiteVendasAPrazo;

  Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.saldoPendente,
    required this.idMotoristaResp,
    required this.nomeMotoristaResp,
    this.permiteVendasAPrazo = true,
  });

  factory Cliente.fromMap(Map<String, dynamic> data, String id) {
    final env = data['endereco'] ?? {};
    final fin = data['financeiro'] ?? {};
    final mot = data['motoristaResponsavel'] ?? {};

    return Cliente(
      id: id,
      nome: data['nome'] ?? '',
      telefone: data['telefone'] ?? '',
      endereco: Endereco.fromMap(Map<String, dynamic>.from(env)),
      saldoPendente: (fin['saldoPendente'] ?? 0.0).toDouble(),
      idMotoristaResp: mot['id'] ?? 'id_fixo_por_enquanto',
      nomeMotoristaResp: mot['nome'] ?? 'nome_fixo_por_enquanto',
      permiteVendasAPrazo: data['permiteVendasAPrazo'] is bool
          ? data['permiteVendasAPrazo'] as bool
          : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco.toMap(),
      'financeiro': {
        'saldoPendente': saldoPendente,
      },
      'motoristaResponsavel': {
        'id': idMotoristaResp,
        'nome': nomeMotoristaResp,
      },
      'permiteVendasAPrazo': permiteVendasAPrazo,
    };
  }
}
