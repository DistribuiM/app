import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/data_row_press_color.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/cubit/session_state.dart';
import '../../domain/entities/entrega.dart';
import '../cubit/delivery_list_cubit.dart';
import '../cubit/delivery_list_state.dart';

class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  String? _selectedEntregaId;

  // AGRUPA POR MOTORISTA
  Map<String, List<Entrega>> _agruparPorMotorista(List<Entrega> entregas) {
    final Map<String, List<Entrega>> agrupado = {};
    for (final entrega in entregas) {
      final nomeMotorista = entrega.nomeMotorista;
      agrupado.putIfAbsent(nomeMotorista, () => []).add(entrega);
    }
    return agrupado;
  }

  Future<void> _abrirDetalhe(Entrega entrega) async {
    if (_selectedEntregaId != null) return;
    setState(() => _selectedEntregaId = entrega.id);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    await context.push(
      '/deliveries/${entrega.id}',
      extra: entrega,
    );

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

          final entregas = (state as DeliveryListLoaded).entregas;

          if (entregas.isEmpty) {
            return const Center(child: Text("Nenhuma entrega registrada"));
          }

          final agrupado = _agruparPorMotorista(entregas);

          return ListView(
            children: agrupado.entries.map((entry) {
              final motorista = entry.key;
              final entregasDoMotorista = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecalho do motorista
                  Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          motorista,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${entregasDoMotorista.length} entrega(s)",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabela de entregas
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: _selectedEntregaId == null ? 0 : 1,
                      ),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, progress, child) {
                        final selectedColor = Colors.black.withValues(
                          alpha: 0.12 * progress,
                        );
                        return DataTable(
                      showCheckboxColumn: false,
                      headingRowColor: const WidgetStatePropertyAll(
                        Color(0xFFF5F5F5),
                      ), // Substituindo Colors.grey[100]
                      columns: const [
                        DataColumn(
                          label: Text(
                            "Data",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Cliente",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Sacos",
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
                            "Pagamento",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Cidade",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(label: SizedBox.shrink()),
                      ],
                      rows: entregasDoMotorista.map((entrega) {
                        return DataRow(
                          selected: _selectedEntregaId == entrega.id,
                          color: _selectedEntregaId == entrega.id
                              ? WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return selectedColor;
                                  }
                                  return null;
                                })
                              : dataRowPressColor,
                          onSelectChanged: (selected) {
                            if (selected == true) {
                              _abrirDetalhe(entrega);
                            }
                          },
                          cells: [
                            DataCell(Text(entrega.dataEntrega)),
                            DataCell(Text(entrega.nomeCliente)),
                            DataCell(Text("${entrega.quantidadeSacos}")),
                            DataCell(
                              Text(
                                "R\$${entrega.valorPago.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: entrega.pago
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text(entrega.formaPagamento)),
                            DataCell(Text(entrega.cidadeCliente)),
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

                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color.fromARGB(120, 158, 158, 158),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
