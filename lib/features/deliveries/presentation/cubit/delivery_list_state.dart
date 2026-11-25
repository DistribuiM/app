import 'package:equatable/equatable.dart';

import '../../domain/entities/entrega.dart';
import '../../domain/entities/filtros_entrega.dart';
import '../../../payments/domain/entities/pagamento.dart';

sealed class DeliveryListState extends Equatable {
  const DeliveryListState();

  @override
  List<Object?> get props => [];
}

class DeliveryListLoading extends DeliveryListState {}

class DeliveryListLoaded extends DeliveryListState {
  const DeliveryListLoaded(
    this.entregas, {
    this.pagamentos = const [],
    List<Entrega>? entregasSemFiltro,
    List<Pagamento>? pagamentosSemFiltro,
    this.filtros = const FiltrosEntrega(),
  }) : entregasSemFiltro = entregasSemFiltro ?? entregas,
       pagamentosSemFiltro = pagamentosSemFiltro ?? pagamentos;

  final List<Entrega> entregas;
  final List<Pagamento> pagamentos;
  final List<Entrega> entregasSemFiltro;
  final List<Pagamento> pagamentosSemFiltro;
  final FiltrosEntrega filtros;

  @override
  List<Object?> get props => [
    entregas,
    pagamentos,
    entregasSemFiltro,
    pagamentosSemFiltro,
    filtros,
  ];
}

class DeliveryListError extends DeliveryListState {
  const DeliveryListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
