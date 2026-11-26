import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../../clients/domain/repositories/client_repository.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/entities/filtros_entrega.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../../../payments/domain/entities/pagamento.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import 'delivery_list_state.dart';

class DeliveryListCubit extends Cubit<DeliveryListState> {
  DeliveryListCubit(
    this._deliveryRepository,
    this._clientRepository,
    this._paymentRepository,
  ) : super(DeliveryListLoading());

  final DeliveryRepository _deliveryRepository;
  final ClientRepository _clientRepository;
  final PaymentRepository _paymentRepository;
  StreamSubscription<List<Entrega>>? _entregasSubscription;
  StreamSubscription<List<Cliente>>? _clientesSubscription;
  StreamSubscription<List<Pagamento>>? _pagamentosSubscription;
  List<Entrega>? _entregasSemFiltro;
  List<Pagamento>? _pagamentosSemFiltro;
  Map<String, Cliente> _clientes = {};
  FiltrosEntrega _filtros = const FiltrosEntrega();
  int _requestId = 0;

  void ouvirEntregas(Usuario usuario) {
    final requestId = ++_requestId;
    unawaited(_cancelarAssinaturas());
    _entregasSemFiltro = null;
    _pagamentosSemFiltro = null;
    _clientes = {};
    emit(DeliveryListLoading());

    final idMotorista = usuario.isAdmin ? null : usuario.id;
    try {
      _clientesSubscription = _clientRepository
          .ouvirClientes(idMotorista: idMotorista)
          .listen(
            (clientes) {
              if (requestId != _requestId) return;
              _clientes = {for (final cliente in clientes) cliente.id: cliente};
              _emitirEntregasFiltradas();
            },
            onError: (Object error) {
              if (requestId == _requestId) {
                debugPrint('Erro ao ouvir clientes: $error');
              }
            },
          );
    } catch (error) {
      debugPrint('Erro ao ouvir clientes: $error');
    }

    try {
      _entregasSubscription = _deliveryRepository
          .ouvirEntregas(idMotorista: idMotorista)
          .listen((entregas) {
            if (requestId != _requestId) return;
            _entregasSemFiltro = entregas;
            _emitirEntregasFiltradas();
          }, onError: (Object error) => _emitirErro(error, requestId));
      _pagamentosSubscription = _paymentRepository
          .ouvirPagamentos(idMotorista: idMotorista)
          .listen((pagamentos) {
            if (requestId != _requestId) return;
            _pagamentosSemFiltro = pagamentos;
            _emitirEntregasFiltradas();
          }, onError: (Object error) => _emitirErro(error, requestId));
    } catch (error) {
      _emitirErro(error, requestId);
    }
  }

  void _emitirErro(Object error, int requestId) {
    if (requestId != _requestId) return;
    _requestId++;
    unawaited(_cancelarAssinaturas());
    final message = error is Failure
        ? error.message
        : 'Não foi possível carregar entregas e pagamentos. Tente novamente.';
    emit(DeliveryListError(message));
  }

  void aplicarFiltros(FiltrosEntrega filtros) {
    _filtros = filtros;
    if (state is DeliveryListLoaded) {
      _emitirEntregasFiltradas();
    }
  }

  void removerFiltro(CampoFiltroEntrega campo) {
    aplicarFiltros(_filtros.sem(campo));
  }

  void limparFiltros() {
    aplicarFiltros(const FiltrosEntrega());
  }

  void _emitirEntregasFiltradas() {
    final entregas = _entregasSemFiltro;
    final pagamentos = _pagamentosSemFiltro;
    if (entregas == null || pagamentos == null) return;

    emit(
      DeliveryListLoaded(
        entregas
            .where(
              (entrega) => _correspondeAosFiltros(
                data: entrega.dataEntrega,
                idMotorista: entrega.idMotorista,
                idCliente: entrega.idCliente,
                formaPagamento: entrega.formaPagamento,
                tipoFormulario: TipoFormularioEntrega.entrega,
                cidade:
                    _clientes[entrega.idCliente]?.endereco.cidade ??
                    entrega.cidadeCliente,
                quantidadeSacos: entrega.quantidadeSacos,
                valorPago: entrega.valorPago,
              ),
            )
            .toList(),
        clientes: _clientes,
        pagamentos: pagamentos
            .where(
              (pagamento) => _correspondeAosFiltros(
                data: pagamento.data,
                idMotorista: pagamento.idMotorista,
                idCliente: pagamento.idCliente,
                formaPagamento: pagamento.formaPagamento,
                tipoFormulario: TipoFormularioEntrega.pagamento,
                cidade:
                    _clientes[pagamento.idCliente]?.endereco.cidade ??
                    pagamento.cidadeCliente,
                quantidadeSacos: null,
                valorPago: pagamento.valor,
              ),
            )
            .toList(),
        entregasSemFiltro: entregas,
        pagamentosSemFiltro: pagamentos,
        filtros: _filtros,
      ),
    );
  }

  bool _correspondeAosFiltros({
    required String data,
    required String idMotorista,
    required String idCliente,
    required String formaPagamento,
    required TipoFormularioEntrega tipoFormulario,
    required String cidade,
    required int? quantidadeSacos,
    required double valorPago,
  }) {
    final filtros = _filtros;
    if (filtros.idMotorista != null && idMotorista != filtros.idMotorista) {
      return false;
    }
    if (filtros.idCliente != null && idCliente != filtros.idCliente) {
      return false;
    }
    if (filtros.formaPagamento != null &&
        formaPagamento != filtros.formaPagamento) {
      return false;
    }
    if (filtros.tipoFormulario != null &&
        filtros.tipoFormulario != tipoFormulario) {
      return false;
    }
    if (filtros.cidade != null && cidade != filtros.cidade) {
      return false;
    }
    if (filtros.quantidadeMinima != null || filtros.quantidadeMaxima != null) {
      if (quantidadeSacos == null) return false;
      if (filtros.quantidadeMinima != null &&
          quantidadeSacos < filtros.quantidadeMinima!) {
        return false;
      }
      if (filtros.quantidadeMaxima != null &&
          quantidadeSacos > filtros.quantidadeMaxima!) {
        return false;
      }
    }
    if (filtros.valorPagoMinimo != null &&
        valorPago < filtros.valorPagoMinimo!) {
      return false;
    }
    if (filtros.valorPagoMaximo != null &&
        valorPago > filtros.valorPagoMaximo!) {
      return false;
    }
    if (filtros.dataInicial != null || filtros.dataFinal != null) {
      final dataRegistro = _parseData(data);
      if (dataRegistro == null) return false;
      if (filtros.dataInicial != null &&
          dataRegistro.isBefore(_inicioDoDia(filtros.dataInicial!))) {
        return false;
      }
      if (filtros.dataFinal != null &&
          dataRegistro.isAfter(_fimDoDia(filtros.dataFinal!))) {
        return false;
      }
    }
    return true;
  }

  DateTime? _parseData(String valor) {
    for (final formato in ['dd/MM/yyyy', 'd/M/yyyy', 'yyyy-MM-dd']) {
      try {
        final data = DateFormat(formato).parseStrict(valor);
        return DateTime(data.year, data.month, data.day);
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  DateTime _inicioDoDia(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  DateTime _fimDoDia(DateTime data) =>
      DateTime(data.year, data.month, data.day, 23, 59, 59, 999);

  Future<void> _cancelarAssinaturas() async {
    final entregasSubscription = _entregasSubscription;
    final clientesSubscription = _clientesSubscription;
    final pagamentosSubscription = _pagamentosSubscription;
    _entregasSubscription = null;
    _clientesSubscription = null;
    _pagamentosSubscription = null;
    await entregasSubscription?.cancel();
    await clientesSubscription?.cancel();
    await pagamentosSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    _requestId++;
    await _cancelarAssinaturas();
    await super.close();
  }
}
