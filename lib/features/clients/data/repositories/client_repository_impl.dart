import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_data_source.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl(this._clientRemoteDataSource);

  final ClientRemoteDataSource _clientRemoteDataSource;

  @override
  Future<List<Cliente>> buscarClientes({String? idMotorista}) async {
    try {
      return await _clientRemoteDataSource.buscarClientes(
        idMotorista: idMotorista,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao carregar clientes: $e');
      throw ServerFailure(
        'Não foi possível carregar os clientes. Tente novamente.',
      );
    }
  }

  @override
  Stream<List<Cliente>> ouvirClientes({String? idMotorista}) async* {
    try {
      await for (final clientes in _clientRemoteDataSource.ouvirClientes(
        idMotorista: idMotorista,
      )) {
        yield clientes;
      }
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao carregar clientes: $e');
      throw ServerFailure(
        'Não foi possível carregar os clientes. Tente novamente.',
      );
    }
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
  }) async {
    try {
      await _clientRemoteDataSource.registrarCliente(
        nome: nome,
        rua: rua,
        complemento: complemento,
        cidade: cidade,
        telefone: telefone,
        idMotoristaResp: idMotoristaResp,
        nomeMotoristaResp: nomeMotoristaResp,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao registrar cliente: $e');
      throw ServerFailure('Não foi possível salvar o cliente. Tente novamente.');
    }
  }

  @override
  Future<void> atualizarCliente({
    required String id,
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    String? idMotoristaResp,
    String? nomeMotoristaResp,
  }) async {
    try {
      await _clientRemoteDataSource.atualizarCliente(
        id: id,
        nome: nome,
        rua: rua,
        complemento: complemento,
        cidade: cidade,
        telefone: telefone,
        idMotoristaResp: idMotoristaResp,
        nomeMotoristaResp: nomeMotoristaResp,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao atualizar cliente: $e');
      throw ServerFailure(
        'Não foi possível atualizar o cliente. Tente novamente.',
      );
    }
  }
}
