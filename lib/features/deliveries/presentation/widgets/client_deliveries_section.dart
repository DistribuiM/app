import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../cubit/client_deliveries_cubit.dart';
import '../cubit/delivery_list_state.dart';

class ClientDeliveriesSection extends StatelessWidget {
  const ClientDeliveriesSection({super.key, required this.idCliente});

  final String idCliente;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientDeliveriesCubit>(
      create: (_) =>
          getIt<ClientDeliveriesCubit>()..ouvirEntregasDoCliente(idCliente),
      child: BlocBuilder<ClientDeliveriesCubit, DeliveryListState>(
        builder: (context, state) {
          if (state is DeliveryListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (state is DeliveryListError) {
            return const Text(
              "Erro ao carregar entregas",
              style: TextStyle(color: Colors.red),
            );
          }

          final todasEntregas = (state as DeliveryListLoaded).entregas;
          final ultimas5 = todasEntregas.take(5).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Entregas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      "${todasEntregas.length}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
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
                        "Qtd.",
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
                        "Pendente",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: ultimas5.map((entrega) {
                    return DataRow(
                      onSelectChanged: (_) => context.push(
                        '/deliveries/${entrega.id}',
                        extra: entrega,
                      ),
                      cells: [
                        DataCell(Text(entrega.dataEntrega)),
                        DataCell(Text("${entrega.quantidadeSacos}")),
                        DataCell(
                          Text(
                            "R\$${entrega.valorPago.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: entrega.pago
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            "R\$${entrega.valorPendente.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: entrega.pago
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              if (todasEntregas.length > 5)
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
