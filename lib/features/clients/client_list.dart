import 'package:flutter/material.dart';
import 'client_repository.dart';
import '../deliveries/delivery_form.dart';
import 'client_details.dart';
import 'cliente.dart';

class ClientList extends StatefulWidget {
  const ClientList({super.key});

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  final ClientRepository _service = ClientRepository();

  List<Cliente> _clientes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await _service.buscarClientes();
    setState(() {
      _clientes = clientes;
      _carregando = false;
    });
  }

  // Agrupa a lista plana de clientes por cidade
  Map<String, List<Cliente>> _agruparPorCidade() {
    final Map<String, List<Cliente>> agrupado = {};
    for (final cliente in _clientes) {
      final cidade = cliente.endereco.cidade;
      agrupado.putIfAbsent(cidade, () => []).add(cliente);
    }
    return agrupado;
  }
  
  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    final agrupado = _agruparPorCidade();

    return ListView(
      children: agrupado.entries.map((entry) {
        final cidade = entry.key;
        final clientes = entry.value;
        return Column(
          children: [
            // Cabecalho da cidade
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                cidade,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            // Clientes da cidade
            ...clientes.map((cliente) => Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientePage(cliente: cliente),
                      ),
                    );
                  },
                  child:Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.group, color: Colors.green[700]),
                                      const SizedBox(width: 8),
                                      Text(
                                        cliente.nome,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cliente.endereco.rua,
                                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "R\$${cliente.saldoPendente.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 212, 30, 17),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DeliveryForm()),
                                );
                              },
                              icon: const Icon(Icons.add),
                            ),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                            IconButton(
                              onPressed: () {
                                // final telefone = cliente['telefone'];
                                // abrir discador
                              },
                              icon: const Icon(Icons.phone),
                            ),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color.fromARGB(120, 158, 158, 158)),
              ],
            )),
          ],
        );
      }).toList(),
    );
  }
}