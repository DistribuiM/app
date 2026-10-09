import '../../domain/entities/cliente.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_data_source.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl(this._clientRemoteDataSource);

  final ClientRemoteDataSource _clientRemoteDataSource;

  @override
  Future<List<Cliente>> buscarClientes() {
    return _clientRemoteDataSource.buscarClientes();
  }

  @override
  Future<void> registrarCliente({
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    required String idMotoristaResp,
    required String nomeMotoristaResp,
  }) {
    return _clientRemoteDataSource.registrarCliente(
      nome: nome,
      rua: rua,
      complemento: complemento,
      cidade: cidade,
      telefone: telefone,
      idMotoristaResp: idMotoristaResp,
      nomeMotoristaResp: nomeMotoristaResp,
    );
  }
}
