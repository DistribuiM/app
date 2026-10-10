import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_remote_data_source.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  UsuarioRepositoryImpl(this._usuarioRemoteDataSource);

  final UsuarioRemoteDataSource _usuarioRemoteDataSource;

  @override
  Future<List<Usuario>> buscarMotoristas() {
    return _usuarioRemoteDataSource.buscarMotoristas();
  }
}
