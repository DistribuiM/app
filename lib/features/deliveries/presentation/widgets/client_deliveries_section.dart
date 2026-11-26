import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/data_row_press_color.dart';
import '../../domain/entities/entrega.dart';
import '../../../payments/domain/entities/pagamento.dart';
import '../cubit/client_deliveries_cubit.dart';
import '../cubit/delivery_list_state.dart';

class ClientDeliveriesSection extends StatefulWidget {
  const ClientDeliveriesSection({
    super.key,
    required this.idCliente,
    this.leadingAction,
  });

  final String idCliente;
  final Widget? leadingAction;

  @override
  State<ClientDeliveriesSection> createState() =>
      _ClientDeliveriesSectionState();
}

class _ClientDeliveriesSectionState extends State<ClientDeliveriesSection> {
  String? _selectedRegistroKey;

  Future<void> _abrirDetalhe(Entrega entrega) async {
    await _abrirRegistro(
      chave: 'entrega:${entrega.id}',
      rota: '/deliveries/${entrega.id}',
      extra: entrega,
    );
  }

  Future<void> _abrirDetalhePagamento(Pagamento pagamento) async {
    await _abrirRegistro(
      chave: 'pagamento:${pagamento.id}',
      rota: '/payments/${pagamento.id}',
      extra: pagamento,
    );
  }

  Future<void> _abrirRegistro({
    required String chave,
    required String rota,
    required Object extra,
  }) async {
    if (_selectedRegistroKey != null) return;
    setState(() => _selectedRegistroKey = chave);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    await context.push(rota, extra: extra);

    if (mounted) {
      setState(() => _selectedRegistroKey = null);
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientDeliveriesCubit>(
      create: (_) =>
          getIt<ClientDeliveriesCubit>()
            ..ouvirEntregasDoCliente(widget.idCliente),
      child: BlocBuilder<ClientDeliveriesCubit, DeliveryListState>(
        builder: (context, state) {
          if (state is DeliveryListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (state is DeliveryListError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () => context
                      .read<ClientDeliveriesCubit>()
                      .ouvirEntregasDoCliente(widget.idCliente),
                  child: const Text('Tentar novamente'),
                ),
              ],
            );
          }

          final loaded = state as DeliveryListLoaded;
          final registros =
              <_RegistroCliente>[
                ...loaded.entregas.map(_RegistroCliente.deEntrega),
                ...loaded.pagamentos.map(_RegistroCliente.dePagamento),
              ]..sort((a, b) {
                final dataA = _parseData(a.data);
                final dataB = _parseData(b.data);
                if (dataA == null) {
                  return dataB == null ? a.data.compareTo(b.data) : 1;
                }
                if (dataB == null) return -1;
                return dataB.compareTo(dataA);
              });
          final ultimas5 = registros.take(5).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          "Entregas",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${registros.length}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.leadingAction != null) widget.leadingAction!,
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: _selectedRegistroKey == null ? 0 : 1,
                  ),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, progress, child) {
                    return DataTable(
                      showCheckboxColumn: false,
                      headingRowColor: WidgetStatePropertyAll(Colors.grey[100]),
                      columns: const [
                        DataColumn(
                          label: Text(
                            "Data",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Tipo / Qtd.",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Valor Pago",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Forma",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Pendente",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(label: SizedBox.shrink()),
                      ],
                      rows: ultimas5.map((registro) {
                        final entrega = registro.entrega;
                        final pagamento = registro.pagamento;
                        final selecionado =
                            _selectedRegistroKey == registro.chave;
                        final valorPago =
                            entrega?.valorPago ?? pagamento!.valor;
                        final formaPagamento =
                            entrega?.formaPagamento ??
                            pagamento!.formaPagamento;
                        final corPagamento = entrega == null || entrega.pago
                            ? Colors.green[700]
                            : Colors.red[700];

                        return DataRow(
                          selected: selecionado,
                          color: selecionado
                              ? dataRowSelectedColor
                              : dataRowPressColor,
                          onSelectChanged: (selected) {
                            if (selected != true) return;
                            if (entrega != null) {
                              _abrirDetalhe(entrega);
                            } else if (pagamento != null) {
                              _abrirDetalhePagamento(pagamento);
                            }
                          },
                          cells: [
                            DataCell(Text(registro.data)),
                            DataCell(
                              Text(
                                entrega == null
                                    ? 'Pagamento'
                                    : '${entrega.quantidadeSacos} sacos',
                              ),
                            ),
                            DataCell(
                              Text(
                                "R\$${valorPago.toStringAsFixed(2)}",
                                style: TextStyle(color: corPagamento),
                              ),
                            ),
                            DataCell(Text(formaPagamento)),
                            DataCell(
                              Text(
                                entrega == null
                                    ? '—'
                                    : "R\$${entrega.valorPendente.toStringAsFixed(2)}",
                                style: TextStyle(color: corPagamento),
                              ),
                            ),
                            DataCell(
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              if (registros.length > 5)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Ver mais",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RegistroCliente {
  const _RegistroCliente({required this.data, this.entrega, this.pagamento});

  factory _RegistroCliente.deEntrega(Entrega entrega) =>
      _RegistroCliente(data: entrega.dataEntrega, entrega: entrega);

  factory _RegistroCliente.dePagamento(Pagamento pagamento) =>
      _RegistroCliente(data: pagamento.data, pagamento: pagamento);

  final String data;
  final Entrega? entrega;
  final Pagamento? pagamento;

  String get chave =>
      '${entrega == null ? 'pagamento' : 'entrega'}:${entrega?.id ?? pagamento!.id}';
}
