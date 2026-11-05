import '../entities/cliente.dart';

abstract class ClientRepository {
  Future<Cliente?> buscarCliente(String id);

  Future<List<Cliente>> buscarClientes({String? idMotorista});

  Stream<List<Cliente>> ouvirClientes({String? idMotorista});

  Future<void> registrarCliente({
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    required String idMotoristaResp,
    required String nomeMotoristaResp,
    bool permiteVendasAPrazo = true,
  });

  Future<void> atualizarCliente({
    required String id,
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    String? idMotoristaResp,
    String? nomeMotoristaResp,
    bool permiteVendasAPrazo = true,
  });
}
