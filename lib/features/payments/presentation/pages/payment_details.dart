import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/cubit/session_state.dart';
import '../../domain/entities/pagamento.dart';
import '../cubit/payment_delete_cubit.dart';
import '../cubit/payment_delete_state.dart';
import '../cubit/payment_details_cubit.dart';
import '../cubit/payment_details_state.dart';

class PagamentoPage extends StatelessWidget {
  const PagamentoPage({super.key, required this.pagamento});

  final Pagamento pagamento;

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    final usuario = sessionState is SessionAuthenticated
        ? sessionState.usuario
        : null;

    return BlocProvider<PaymentDeleteCubit>(
      create: (_) => getIt<PaymentDeleteCubit>(),
      child: BlocListener<PaymentDeleteCubit, PaymentDeleteState>(
        listener: (context, state) {
          if (state is PaymentDeleteSuccess) {
            context.pop();
          } else if (state is PaymentDeleteError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocProvider(
          create: (_) =>
              getIt<PaymentDetailsCubit>()..ouvirPagamento(pagamento),
          child: BlocBuilder<PaymentDetailsCubit, PaymentDetailsState>(
            builder: (context, state) {
              final pagamentoAtual = state is PaymentDetailsLoaded
                  ? state.pagamento
                  : null;
              final podeEditar =
                  pagamentoAtual != null &&
                  usuario != null &&
                  (usuario.isAdmin || pagamentoAtual.idMotorista == usuario.id);

              return Scaffold(
                backgroundColor: const Color(0xFFF7F8F5),
                appBar: CustomAppBar(
                  title: 'Detalhe do Pagamento',
                  leading: true,
                  actions: [
                    if (pagamentoAtual != null && usuario?.isAdmin == true)
                      BlocBuilder<PaymentDeleteCubit, PaymentDeleteState>(
                        builder: (context, deleteState) {
                          if (deleteState is PaymentDeleteLoading) {
                            return const IconButton(
                              onPressed: null,
                              tooltip: 'Excluindo pagamento',
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
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            tooltip: 'Opções do pagamento',
                            onSelected: (opcao) async {
                              if (opcao != 'excluir') return;
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Excluir pagamento?'),
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
                              if (confirmar != true || !context.mounted) {
                                return;
                              }
                              final atual = context.read<SessionCubit>().state;
                              if (atual is SessionAuthenticated) {
                                context
                                    .read<PaymentDeleteCubit>()
                                    .excluirPagamento(
                                      atual.usuario,
                                      pagamentoAtual.id,
                                    );
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'excluir',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Excluir pagamento',
                                        style: TextStyle(color: Colors.red),
                                      ),
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
                body: SafeArea(
                  child: switch (state) {
                    PaymentDetailsLoaded loaded => _buildPagamentoContent(
                      loaded.pagamento,
                    ),
                    PaymentDetailsNotFound() => const Center(
                      child: Text('Pagamento não encontrado'),
                    ),
                    PaymentDetailsError(:final message) => Center(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    PaymentDetailsInitial() => const SizedBox.shrink(),
                  },
                ),
                floatingActionButton: podeEditar
                    ? FloatingActionButton(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        tooltip: 'Editar pagamento',
                        onPressed: () => context.push(
                          '/payments/${pagamentoAtual.id}/edit',
                          extra: pagamentoAtual,
                        ),
                        child: const Icon(Icons.edit),
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPagamentoContent(Pagamento pagamento) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label(text: 'Cliente'),
          Row(
            children: [
              Icon(Icons.person, color: Colors.green[700], size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pagamento.nomeCliente,
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
          const SizedBox(height: 20),
          const _Label(text: 'Cidade'),
          Text(pagamento.cidadeCliente, style: const TextStyle(fontSize: 16)),
          const Divider(),
          const SizedBox(height: 12),
          const _Label(text: 'Data do Pagamento'),
          Text(pagamento.data, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          const _Label(text: 'Motorista'),
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                pagamento.nomeMotorista,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _Label(text: 'Forma de Pagamento'),
          Text(pagamento.formaPagamento, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          const _Label(text: 'Valor Pago'),
          Text(
            'R\$${pagamento.valor.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, color: Colors.green[700]),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

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
