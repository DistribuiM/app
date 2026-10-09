import '../entities/cliente.dart';

abstract class ClientRepository {
  Future<List<Cliente>> buscarClientes();

  Future<void> registrarCliente({
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    required String idMotoristaResp,
    required String nomeMotoristaResp,
  });
}
