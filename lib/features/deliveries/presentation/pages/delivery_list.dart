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
import '../cubit/delivery_list_cubit.dart';
import '../cubit/delivery_list_state.dart';

class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  String? _selectedEntregaId;
  final Set<String> _diasExpandidos = {};

  List<_EntregaDia> _agruparPorDia(List<Entrega> entregas) {
    final agrupado = <String, _EntregaDia>{};
    for (final entrega in entregas) {
      final data = _parseData(entrega.dataEntrega);
      final chave = data == null
          ? 'invalida:${entrega.dataEntrega}'
          : '${data.year}-${data.month}-${data.day}';
      final grupo = agrupado.putIfAbsent(
        chave,
        () => _EntregaDia(
          chave: chave,
          data: data,
          rotulo: data == null
              ? (entrega.dataEntrega.isEmpty
                    ? 'Data não informada'
                    : entrega.dataEntrega)
              : DateFormat('d/M/yyyy').format(data),
        ),
      );
      grupo.entregas.add(entrega);
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
    for (final formato in ['dd/MM/yyyy', 'd/M/yyyy']) {
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
          if (state is DeliveryListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (state is DeliveryListError) {
            return const Center(
              child: Text(
                "Erro ao carregar entregas",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final carregado = state as DeliveryListLoaded;
          final entregas = carregado.entregas;

          if (entregas.isEmpty) {
            return const Center(child: Text("Nenhuma entrega registrada"));
          }

          final dias = _agruparPorDia(entregas);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${dia.entregas.length}',
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
                                duration: const Duration(milliseconds: 180),
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
                              dia.entregas,
                              carregado.clientes,
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEntregasPorMotorista(
    List<Entrega> entregas,
    Map<String, Cliente> clientes,
  ) {
    final agrupado = <String, _EntregasMotorista>{};
    for (final entrega in entregas) {
      final motorista = agrupado.putIfAbsent(
        entrega.idMotorista,
        () => _EntregasMotorista(
          id: entrega.idMotorista,
          nome: entrega.nomeMotorista,
        ),
      );
      motorista.entregas.add(entrega);
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
                      '${motorista.entregas.length}',
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
              child: _buildTabelaEntregas(motorista.entregas, clientes),
            ),
            const Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }

  DataTable _buildTabelaEntregas(
    List<Entrega> entregas,
    Map<String, Cliente> clientes,
  ) {
    return DataTable(
      showCheckboxColumn: false,
      headingRowColor: const WidgetStatePropertyAll(Color(0xFFF5F5F5)),
      columns: const [
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
      rows: entregas.map((entrega) {
        return DataRow(
          selected: _selectedEntregaId == entrega.id,
          color: _selectedEntregaId == entrega.id
              ? dataRowSelectedColor
              : dataRowPressColor,
          onSelectChanged: (selected) {
            if (selected == true) {
              _abrirDetalhe(entrega);
            }
          },
          cells: [
            DataCell(Text(entrega.dataEntrega)),
            DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  _nomeCliente(entrega, clientes),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(Text("${entrega.quantidadeSacos}")),
            DataCell(
              Text(
                "R\$${entrega.valorPago.toStringAsFixed(2)}",
                style: TextStyle(
                  color: entrega.pago ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(Text(entrega.formaPagamento)),
            DataCell(Text(_cidadeCliente(entrega, clientes))),
            DataCell(
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
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
  final List<Entrega> entregas = [];
}

class _EntregasMotorista {
  _EntregasMotorista({required this.id, required this.nome});

  final String id;
  final String nome;
  final List<Entrega> entregas = [];
}
