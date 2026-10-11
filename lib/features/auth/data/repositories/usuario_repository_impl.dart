import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_remote_data_source.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  UsuarioRepositoryImpl(this._usuarioRemoteDataSource);

  final UsuarioRemoteDataSource _usuarioRemoteDataSource;

  @override
  Future<List<Usuario>> buscarMotoristas() async {
    try {
      return await _usuarioRemoteDataSource.buscarMotoristas();
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao carregar motoristas: $e');
      throw ServerFailure(
        'Não foi possível carregar os motoristas. Tente novamente.',
      );
    }
  }
}
