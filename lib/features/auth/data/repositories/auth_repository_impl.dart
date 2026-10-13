import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/usuario_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.usuarioRemoteDataSource,
  });

  final AuthRemoteDataSource authRemoteDataSource;
  final UsuarioRemoteDataSource usuarioRemoteDataSource;

  @override
  Stream<Usuario?> get sessionChanges =>
      authRemoteDataSource.emailChanges.asyncMap((email) {
        if (email == null) {
          return null;
        }
        return usuarioRemoteDataSource.buscarMotoristaPorId(email);
      });

  @override
  Future<Usuario> signInWithGoogle() async {
    late final String email;
    try {
      email = await authRemoteDataSource.signInWithGoogle();
    } catch (e) {
      debugPrint('Erro ao entrar com o Google: $e');
      throw const AuthFailure(
        'Não foi possível entrar com o Google. Tente novamente.',
      );
    }

    late final Usuario? usuario;
    try {
      usuario = await usuarioRemoteDataSource.buscarMotoristaPorId(email);
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao verificar o cadastro do motorista: $e');
      try {
        await authRemoteDataSource.signOut();
      } catch (_) {}
      throw const ServerFailure(
        'Não foi possível verificar seu cadastro. Verifique sua conexão e '
        'tente novamente.',
      );
    }

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
