import 'package:flutter/material.dart';
import 'entrega_service.dart';
import 'entrega.dart';

class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  final EntregaService _service = EntregaService();

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
    // USA STREAM BUILDER PARA OUVIR SE TEVE ALTERACAO NO BANCO DE DADOS E ATUALIZA AUTOMATICAMENTE A TELA
    return StreamBuilder<List<Entrega>>(
      stream: _service.ouvirEntregas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar entregas", style: TextStyle(color: Colors.red)));
        }

        final entregas = snapshot.data ?? [];

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
    );
  }
}