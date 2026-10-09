import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/entrega.dart';
import '../cubit/delivery_list_cubit.dart';
import '../cubit/delivery_list_state.dart';

class DeliveryList extends StatelessWidget {
  const DeliveryList({super.key});

  // AGRUPA POR MOTORISTA
  Map<String, List<Entrega>> _agruparPorMotorista(List<Entrega> entregas) {
    final Map<String, List<Entrega>> agrupado = {};
    for (final entrega in entregas) {
      final nomeMotorista = entrega.nomeMotorista;
      agrupado.putIfAbsent(nomeMotorista, () => []).add(entrega);
    }
    return agrupado;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeliveryListCubit>()..ouvirEntregas(),
      child: BlocBuilder<DeliveryListCubit, DeliveryListState>(
        builder: (context, state) {
          if (state is DeliveryListLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (state is DeliveryListError) {
          return const Center(child: Text("Erro ao carregar entregas", style: TextStyle(color: Colors.red)));
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        motorista,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${entregasDoMotorista.length} entrega(s)",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Tabela de entregas
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: const WidgetStatePropertyAll(Color(0xFFF5F5F5)), // Substituindo Colors.grey[100]
                    columns: const [
                      DataColumn(label: Text("Data", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Sacos", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Valor Pago", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Pagamento", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Cidade", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: entregasDoMotorista.map((entrega) {
                      return DataRow(cells: [
                        DataCell(Text(entrega.dataEntrega)),
                        DataCell(Text(entrega.nomeCliente)),
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
                        DataCell(Text(entrega.cidadeCliente)),
                      ]);
                    }).toList(),
                  ),
                ),

                const Divider(height: 1, thickness: 1, color: Color.fromARGB(120, 158, 158, 158)),
              ],
            );
            }).toList(),
          );
        },
      ),
    );
  }
}