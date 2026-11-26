import '../../domain/entities/cliente.dart';

class ClienteFiltro {
  const ClienteFiltro({
    this.cidade,
    this.idMotorista,
    this.permiteVendasAPrazo,
  });

  final String? cidade;
  final String? idMotorista;
  final bool? permiteVendasAPrazo;

  int get quantidadeAtivos {
    return [cidade, idMotorista, permiteVendasAPrazo]
        .where((valor) => valor != null)
        .length;
  }

  bool aceita(Cliente cliente) {
    if (cidade != null && cliente.endereco.cidade != cidade) return false;
    if (idMotorista != null && cliente.idMotoristaResp != idMotorista) {
      return false;
    }
    if (permiteVendasAPrazo != null &&
        cliente.permiteVendasAPrazo != permiteVendasAPrazo) {
      return false;
    }
    return true;
  }
}