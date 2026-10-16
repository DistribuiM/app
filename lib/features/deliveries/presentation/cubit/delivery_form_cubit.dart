import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../../clients/domain/repositories/client_repository.dart';
import '../../domain/repositories/delivery_repository.dart';
import 'delivery_form_state.dart';

class DeliveryFormCubit extends Cubit<DeliveryFormState> {
  DeliveryFormCubit(
    this._deliveryRepository,
    this._clientRepository,
    this._usuarioRepository,
  ) : super(DeliveryFormLoading());

  final DeliveryRepository _deliveryRepository;
  final ClientRepository _clientRepository;
  final UsuarioRepository _usuarioRepository;

  Future<void> carregarDados(
    Usuario usuario, {
    bool incluirClientes = true,
  }) async {
    emit(DeliveryFormLoading());

    try {
      final motoristas = <Usuario>[];
      if (usuario.isAdmin) {
        motoristas
          ..add(usuario)
          ..addAll(await _usuarioRepository.buscarMotoristas());
      }
      final List<Cliente> clientes = incluirClientes
          ? await _clientRepository.buscarClientes(
              idMotorista: usuario.isAdmin ? null : usuario.id,
            )
          : [];
      emit(DeliveryFormLoaded(motoristas: motoristas, clientes: clientes));
    } catch (e) {
      if (e is Failure) {
        emit(DeliveryFormLoadError(e.message));
      } else {
        emit(const DeliveryFormLoadError('Erro inesperado. Tente novamente.'));
      }
    }
  }

  Future<void> registrarEntrega({
    required String dataEntrega,
    required String idMotorista,
    required String nomeMotorista,
    required String idCliente,
    required String nomeCliente,
    required String cidadeCliente,
    required int quantidadeSacos,
    required double precoUnitario,
    required double valorPago,
    required double valorPendente,
    required String formaPagamento,
    required bool pago,
    required bool entregue,
    required String observacao,
  }) async {
    final currentState = state;
    if (currentState is! DeliveryFormLoaded) return;

    final motoristas = currentState.motoristas;
    final clientes = currentState.clientes;
    emit(DeliveryFormSubmitting(motoristas: motoristas, clientes: clientes));

    try {
      await _deliveryRepository.registrarEntrega(
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        idCliente: idCliente,
        nomeCliente: nomeCliente,
        cidadeCliente: cidadeCliente,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        entregue: entregue,
        observacao: observacao,
      );
      emit(DeliveryFormSuccess());
    } catch (e) {
      if (e is Failure) {
        emit(DeliveryFormError(e.message));
      } else {
        emit(const DeliveryFormError('Erro inesperado. Tente novamente.'));
      }
      emit(DeliveryFormLoaded(motoristas: motoristas, clientes: clientes));
    }
  }

  Future<void> atualizarEntrega({
    required String id,
    required String dataEntrega,
    required String idMotorista,
    required String nomeMotorista,
    required int quantidadeSacos,
    required double precoUnitario,
    required double valorPago,
    required double valorPendente,
    required String formaPagamento,
    required bool pago,
    required String observacao,
  }) async {
    final currentState = state;
    if (currentState is! DeliveryFormLoaded) return;

    final motoristas = currentState.motoristas;
    final clientes = currentState.clientes;
    emit(DeliveryFormSubmitting(motoristas: motoristas, clientes: clientes));

    try {
      await _deliveryRepository.atualizarEntrega(
        id: id,
        dataEntrega: dataEntrega,
        idMotorista: idMotorista,
        nomeMotorista: nomeMotorista,
        quantidadeSacos: quantidadeSacos,
        precoUnitario: precoUnitario,
        valorPago: valorPago,
        valorPendente: valorPendente,
        formaPagamento: formaPagamento,
        pago: pago,
        observacao: observacao,
      );
      emit(DeliveryFormSuccess());
    } catch (e) {
      if (e is Failure) {
        emit(DeliveryFormError(e.message));
      } else {
        emit(const DeliveryFormError('Erro inesperado. Tente novamente.'));
      }
      emit(DeliveryFormLoaded(motoristas: motoristas, clientes: clientes));
    }
  }
}
