import '../../../../core/error/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/usuario_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.usuarioRemoteDataSource,
  });

  final AuthRemoteDataSource authRemoteDataSource;
  final UsuarioRemoteDataSource usuarioRemoteDataSource;

  @override
  Future<Usuario> signInWithGoogle() async {
    final email = await authRemoteDataSource.signInWithGoogle();
    final usuario = await usuarioRemoteDataSource.buscarMotoristaPorId(email);

    if (usuario == null) {
      await authRemoteDataSource.signOut();
      throw AuthFailure(
        'Acesso Negado: O e-mail $email não está cadastrado como motorista.',
      );
    }

    return usuario;
  }

  @override
  Future<void> signOut() async {
    await authRemoteDataSource.signOut();
  }
}
