import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/cliente.dart';
import '../cubit/client_list_cubit.dart';
import '../cubit/client_list_state.dart';

class ClientList extends StatelessWidget {
  const ClientList({super.key});

  // Agrupa a lista plana de clientes por cidade
  Map<String, List<Cliente>> _agruparPorCidade(List<Cliente> clientes) {
    final Map<String, List<Cliente>> agrupado = {};
    for (final cliente in clientes) {
      final cidade = cliente.endereco.cidade;
      agrupado.putIfAbsent(cidade, () => []).add(cliente);
    }
    return agrupado;
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClientListCubit>()..carregarClientes(),
      child: BlocBuilder<ClientListCubit, ClientListState>(
        builder: (context, state) {
          if (state is ClientListInitial || state is ClientListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (state is ClientListError) {
            return Center(child: Text(state.message));
          }

          if (state is! ClientListLoaded) {
            return const SizedBox.shrink();
          }

          final agrupado = _agruparPorCidade(state.clientes);

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      cidade,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  // Clientes da cidade
                  ...clientes.map(
                    (cliente) => Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(
                              '/clients/${cliente.id}',
                              extra: cliente,
                            );
                          },
                          child: Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.group,
                                                color: Colors.green[700],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                cliente.nome,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            cliente.endereco.rua,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
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
                                        context.push('/deliveries/new');
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // final telefone = cliente['telefone'];
                                        // abrir discador
                                      },
                                      icon: const Icon(Icons.phone),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.chat_bubble),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color.fromARGB(120, 158, 158, 158),
                        ),
                      ],
                    ),
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