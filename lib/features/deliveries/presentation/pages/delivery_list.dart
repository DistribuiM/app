import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/data_row_press_color.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/cubit/session_state.dart';
import '../../domain/entities/entrega.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../domain/entities/filtros_entrega.dart';
import '../../../payments/domain/entities/pagamento.dart';
import '../cubit/delivery_list_cubit.dart';
import '../cubit/delivery_list_state.dart';
import '../widgets/delivery_filters_sheet.dart';

class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  @override
  DeliveryListPageState createState() => DeliveryListPageState();
}

class DeliveryListPageState extends State<DeliveryList> {
  String? _selectedEntregaId;
  final Set<String> _diasExpandidos = {};
  DeliveryListCubit? _deliveryListCubit;

  void abrirFiltros() {
    final cubit = _deliveryListCubit;
    final state = cubit?.state;
    if (cubit == null || state is! DeliveryListLoaded) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DeliveryFiltersSheet(
        entregas: state.entregasSemFiltro,
        pagamentos: state.pagamentosSemFiltro,
        clientes: state.clientes,
        filtrosIniciais: state.filtros,
        onApply: cubit.aplicarFiltros,
      ),
    );
  }

  List<_EntregaDia> _agruparPorDia(List<_RegistroLista> registros) {
    final agrupado = <String, _EntregaDia>{};
    for (final registro in registros) {
      final data = _parseData(registro.data);
      final chave = data == null
          ? 'invalida:${registro.data}'
          : '${data.year}-${data.month}-${data.day}';
      final grupo = agrupado.putIfAbsent(
        chave,
        () => _EntregaDia(
          chave: chave,
          data: data,
          rotulo: data == null
              ? (registro.data.isEmpty ? 'Data não informada' : registro.data)
              : DateFormat('d/M/yyyy').format(data),
        ),
      );
      grupo.registros.add(registro);
    }

    final dias = agrupado.values.toList()
      ..sort((a, b) {
        if (a.data == null) {
          return b.data == null ? a.rotulo.compareTo(b.rotulo) : 1;
        }
        if (b.data == null) return -1;
        return b.data!.compareTo(a.data!);
      });
    return dias;
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

  String _nomeCliente(Entrega entrega, Map<String, Cliente> clientes) {
    return clientes[entrega.idCliente]?.nome ?? entrega.nomeCliente;
  }

  String _cidadeCliente(Entrega entrega, Map<String, Cliente> clientes) {
    return clientes[entrega.idCliente]?.endereco.cidade ??
        entrega.cidadeCliente;
  }

  Future<void> _abrirDetalhe(Entrega entrega) async {
    if (_selectedEntregaId != null) return;
    setState(() => _selectedEntregaId = entrega.id);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    await context.push('/deliveries/${entrega.id}', extra: entrega);

    if (mounted) {
      setState(() => _selectedEntregaId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    if (sessionState is! SessionAuthenticated) {
      return const SizedBox.shrink();
    }

    final usuario = sessionState.usuario;
    return BlocProvider(
      create: (_) => getIt<DeliveryListCubit>()..ouvirEntregas(usuario),
      child: BlocBuilder<DeliveryListCubit, DeliveryListState>(
        builder: (context, state) {
          _deliveryListCubit = context.read<DeliveryListCubit>();
          if (state is DeliveryListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (state is DeliveryListError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context
                        .read<DeliveryListCubit>()
                        .ouvirEntregas(usuario),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final loadedState = state as DeliveryListLoaded;
          final registros = [
            ...loadedState.entregas.map(
              (entrega) => _RegistroLista.deEntrega(
                entrega,
                nomeCliente: _nomeCliente(entrega, loadedState.clientes),
                cidadeCliente: _cidadeCliente(entrega, loadedState.clientes),
              ),
            ),
            ...loadedState.pagamentos.map(
              (pagamento) => _RegistroLista.dePagamento(
                pagamento,
                cliente: loadedState.clientes[pagamento.idCliente],
              ),
            ),
          ];
          final dias = _agruparPorDia(registros);

          return Column(
            children: [
              if (!loadedState.filtros.estaVazio)
                _buildTagsFiltros(loadedState, _deliveryListCubit!),
              Expanded(
                child: registros.isEmpty
                    ? Center(
                        child: Text(
                          loadedState.filtros.estaVazio
                              ? 'Nenhuma entrega ou pagamento registrado'
                              : 'Nenhum registro encontrado para esses filtros',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        children: dias.map((dia) {
                          final expandido = _diasExpandidos.contains(dia.chave);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      setState(() {
                                        if (expandido) {
                                          _diasExpandidos.remove(dia.chave);
                                        } else {
                                          _diasExpandidos.add(dia.chave);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 19,
                                            color: Colors.green[700],
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              dia.rotulo,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${dia.registros.length}',
                                              style: TextStyle(
                                                color: Colors.green[800],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AnimatedRotation(
                                            turns: expandido ? 0.25 : 0,
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            child: Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 180),
                                  alignment: Alignment.topCenter,
                                  child: expandido
                                      ? _buildEntregasPorMotorista(
                                          dia.registros,
                                        )
                                      : const SizedBox(width: double.infinity),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTagsFiltros(DeliveryListLoaded state, DeliveryListCubit cubit) {
    final filtros = state.filtros;
    final registrosOriginais = [
      ...state.entregasSemFiltro.map(
        (entrega) => _RegistroLista.deEntrega(
          entrega,
          nomeCliente: _nomeCliente(entrega, state.clientes),
          cidadeCliente: _cidadeCliente(entrega, state.clientes),
        ),
      ),
      ...state.pagamentosSemFiltro.map(
        (pagamento) => _RegistroLista.dePagamento(
          pagamento,
          cliente: state.clientes[pagamento.idCliente],
        ),
      ),
    ];
    final tags = <Widget>[];

    void adicionarTag(CampoFiltroEntrega campo, String rotulo) {
      tags.add(
        InputChip(
          label: Text(rotulo),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => cubit.removerFiltro(campo),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    if (filtros.dataInicial != null || filtros.dataFinal != null) {
      final inicio = filtros.dataInicial == null
          ? '...'
          : DateFormat('dd/MM/yyyy').format(filtros.dataInicial!);
      final fim = filtros.dataFinal == null
          ? '...'
          : DateFormat('dd/MM/yyyy').format(filtros.dataFinal!);
      adicionarTag(CampoFiltroEntrega.periodo, 'Data: $inicio – $fim');
    }
    if (filtros.idMotorista != null) {
      final nome = _nomeMotorista(registrosOriginais, filtros.idMotorista!);
      adicionarTag(CampoFiltroEntrega.motorista, 'Motorista: $nome');
    }
    if (filtros.idCliente != null) {
      final nome = _nomeClienteFiltro(registrosOriginais, filtros.idCliente!);
      adicionarTag(CampoFiltroEntrega.cliente, 'Cliente: $nome');
    }
    if (filtros.formaPagamento != null) {
      adicionarTag(
        CampoFiltroEntrega.formaPagamento,
        'Pagamento: ${filtros.formaPagamento}',
      );
    }
    if (filtros.tipoFormulario != null) {
      final tipo = switch (filtros.tipoFormulario!) {
        TipoFormularioEntrega.entrega => 'Entrega',
        TipoFormularioEntrega.pagamento => 'Pagamento',
      };
      adicionarTag(CampoFiltroEntrega.tipoFormulario, 'Formulário: $tipo');
    }
    if (filtros.cidade != null) {
      adicionarTag(CampoFiltroEntrega.cidade, 'Cidade: ${filtros.cidade}');
    }
    if (filtros.quantidadeMinima != null || filtros.quantidadeMaxima != null) {
      final minimo = filtros.quantidadeMinima?.toString() ?? '...';
      final maximo = filtros.quantidadeMaxima?.toString() ?? '...';
      adicionarTag(
        CampoFiltroEntrega.quantidadeSacos,
        'Sacos: $minimo – $maximo',
      );
    }
    if (filtros.valorPagoMinimo != null || filtros.valorPagoMaximo != null) {
      final minimo = filtros.valorPagoMinimo == null
          ? '...'
          : _formatarMoeda(filtros.valorPagoMinimo!);
      final maximo = filtros.valorPagoMaximo == null
          ? '...'
          : _formatarMoeda(filtros.valorPagoMaximo!);
      adicionarTag(
        CampoFiltroEntrega.valorPago,
        'Valor pago: $minimo – $maximo',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(spacing: 8, runSpacing: 0, children: tags),
    );
  }

  String _nomeMotorista(List<_RegistroLista> registros, String id) {
    for (final registro in registros) {
      if (registro.idMotorista == id) return registro.nomeMotorista;
    }
    return id;
  }

  String _nomeClienteFiltro(List<_RegistroLista> registros, String id) {
    for (final registro in registros) {
      if (registro.idCliente == id) {
        return '${registro.nomeCliente} - ${registro.cidadeCliente}';
      }
    }
    return id;
  }

  String _formatarMoeda(double valor) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);

  Widget _buildEntregasPorMotorista(List<_RegistroLista> registros) {
    final agrupado = <String, _RegistrosMotorista>{};
    for (final registro in registros) {
      final motorista = agrupado.putIfAbsent(
        registro.idMotorista,
        () => _RegistrosMotorista(
          id: registro.idMotorista,
          nome: registro.nomeMotorista,
        ),
      );
      motorista.registros.add(registro);
    }

    final motoristas = agrupado.values.toList()
      ..sort((a, b) {
        final comparacao = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        return comparacao != 0 ? comparacao : a.id.compareTo(b.id);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: motoristas.map((motorista) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    motorista.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${motorista.registros.length}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTabelaEntregas(motorista.registros),
            ),
            const Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }

  DataTable _buildTabelaEntregas(List<_RegistroLista> registros) {
    return DataTable(
      showCheckboxColumn: false,
      headingRowColor: const WidgetStatePropertyAll(Color(0xFFF5F5F5)),
      columns: const [
        DataColumn(
          label: Text("Tipo", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text("Data", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text("Sacos", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            "Valor Pago",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            "Pagamento",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text("Cidade", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(label: SizedBox.shrink()),
      ],
      rows: registros.map((registro) {
        final entrega = registro.entrega;
        return DataRow(
          selected: entrega != null && _selectedEntregaId == entrega.id,
          color: entrega != null && _selectedEntregaId == entrega.id
              ? dataRowSelectedColor
              : dataRowPressColor,
          onSelectChanged: entrega == null
              ? null
              : (selected) {
                  if (selected == true) {
                    _abrirDetalhe(entrega);
                  }
                },
          cells: [
            DataCell(Text(registro.tipo)),
            DataCell(Text(registro.data)),
            DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  registro.nomeCliente,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(Text(registro.quantidadeSacos?.toString() ?? '—')),
            DataCell(
              Text(
                "R\$${registro.valorPago.toStringAsFixed(2)}",
                style: TextStyle(
                  color: entrega == null || entrega.pago
                      ? Colors.green[700]
                      : Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(Text(registro.formaPagamento)),
            DataCell(Text(registro.cidadeCliente)),
            DataCell(
              entrega == null
                  ? const SizedBox.shrink()
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[600],
                    ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _EntregaDia {
  _EntregaDia({required this.chave, required this.data, required this.rotulo});

  final String chave;
  final DateTime? data;
  final String rotulo;
  final List<_RegistroLista> registros = [];
}

class _RegistrosMotorista {
  _RegistrosMotorista({required this.id, required this.nome});

  final String id;
  final String nome;
  final List<_RegistroLista> registros = [];
}

class _RegistroLista {
  const _RegistroLista({
    required this.tipo,
    required this.data,
    required this.idMotorista,
    required this.nomeMotorista,
    required this.idCliente,
    required this.nomeCliente,
    required this.cidadeCliente,
    required this.quantidadeSacos,
    required this.valorPago,
    required this.formaPagamento,
    this.entrega,
  });

  factory _RegistroLista.deEntrega(
    Entrega entrega, {
    String? nomeCliente,
    String? cidadeCliente,
  }) => _RegistroLista(
    tipo: 'Entrega',
    data: entrega.dataEntrega,
    idMotorista: entrega.idMotorista,
    nomeMotorista: entrega.nomeMotorista,
    idCliente: entrega.idCliente,
    nomeCliente: nomeCliente ?? entrega.nomeCliente,
    cidadeCliente: cidadeCliente ?? entrega.cidadeCliente,
    quantidadeSacos: entrega.quantidadeSacos,
    valorPago: entrega.valorPago,
    formaPagamento: entrega.formaPagamento,
    entrega: entrega,
  );

  factory _RegistroLista.dePagamento(Pagamento pagamento, {Cliente? cliente}) =>
      _RegistroLista(
        tipo: 'Pagamento',
        data: pagamento.data,
        idMotorista: pagamento.idMotorista,
        nomeMotorista: pagamento.nomeMotorista,
        idCliente: pagamento.idCliente,
        nomeCliente: cliente?.nome ?? pagamento.nomeCliente,
        cidadeCliente: cliente?.endereco.cidade ?? pagamento.cidadeCliente,
        quantidadeSacos: null,
        valorPago: pagamento.valor,
        formaPagamento: pagamento.formaPagamento,
      );

  final String tipo;
  final String data;
  final String idMotorista;
  final String nomeMotorista;
  final String idCliente;
  final String nomeCliente;
  final String cidadeCliente;
  final int? quantidadeSacos;
  final double valorPago;
  final String formaPagamento;
  final Entrega? entrega;
}
