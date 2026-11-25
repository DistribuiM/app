import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/cubit/session_state.dart';
import '../../domain/entities/cliente.dart';
import '../cubit/client_delete_cubit.dart';
import '../cubit/client_delete_state.dart';
import '../../../deliveries/presentation/widgets/client_deliveries_section.dart';

class ClientePage extends StatefulWidget {
  final Cliente cliente;

  const ClientePage({super.key, required this.cliente});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;
    final endereco = cliente.endereco;
    final sessionState = context.watch<SessionCubit>().state;
    final usuario = sessionState is SessionAuthenticated
        ? sessionState.usuario
        : null;

    return BlocProvider<ClientDeleteCubit>(
      create: (_) => getIt<ClientDeleteCubit>(),
      child: BlocListener<ClientDeleteCubit, ClientDeleteState>(
        listener: (context, state) {
          if (state is ClientDeleteSuccess) {
            context.pop();
          } else if (state is ClientDeleteError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Ficha do Cliente',
            leading: true,
            actions: [
              if (usuario?.isAdmin ?? false)
                BlocBuilder<ClientDeleteCubit, ClientDeleteState>(
                  builder: (context, state) {
                    if (state is ClientDeleteLoading) {
                      return const IconButton(
                        onPressed: null,
                        tooltip: 'Excluindo cliente',
                        icon: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      tooltip: 'Opções do cliente',
                      onSelected: (opcao) async {
                        if (opcao != 'excluir') return;
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Excluir cliente?'),
                            content: const Text(
                              'Esta ação não pode ser desfeita.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => dialogContext.pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => dialogContext.pop(true),
                                child: const Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmar != true || !context.mounted) return;
                        final atual = context.read<SessionCubit>().state;
                        if (atual is SessionAuthenticated) {
                          context.read<ClientDeleteCubit>().excluirCliente(
                            atual.usuario,
                            cliente.id,
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'excluir',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Excluir cliente',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
          backgroundColor: const Color(0xFFF7F8F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do cliente
                  const _Label(text: "Cliente"),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.green[700],
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cliente.nome,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Valor pendente
                  const _Label(text: "Valor Pendente do Cliente"),
                  Text(
                    "R\$${cliente.saldoPendente.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (!cliente.permiteVendasAPrazo)
                    const Text(
                      "Proibido vendas a prazo para esse cliente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Endereço
                  const _Label(text: "Endereço"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${endereco.rua}${endereco.complemento.isNotEmpty ? ', ${endereco.complemento}' : ''}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.location_on, color: Colors.grey[600]),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cidade
                  const _Label(text: "Cidade"),
                  Text(endereco.cidade, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),

                  // Telefone
                  const _Label(text: "Telefone"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cliente.telefone,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Icon(Icons.chat_bubble, color: Colors.grey[600]),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Motorista responsável
                  const _Label(text: "Motorista Responsável"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_shipping, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            cliente.nomeMotoristaResp,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),

                  ClientDeliveriesSection(
                    idCliente: cliente.id,
                    leadingAction: IconButton(
                      onPressed: () =>
                          context.push('/deliveries/new', extra: cliente),
                      icon: Icon(Icons.add, color: Colors.green[700], size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
    );
  }
}
