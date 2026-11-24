import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/cubit/session_state.dart';
import '../../domain/entities/cliente.dart';
import '../cubit/client_list_cubit.dart';
import '../cubit/client_list_state.dart';

class ClientList extends StatefulWidget {
  const ClientList({super.key, this.searchQuery = ''});

  final String searchQuery;

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  final Set<String> _motoristasExpandidos = {};

  bool get _buscaAtiva =>
      _normalizarTexto(widget.searchQuery.trim()).isNotEmpty;

  @override
  void didUpdateWidget(covariant ClientList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final buscaAnteriorAtiva = _normalizarTexto(
      oldWidget.searchQuery.trim(),
    ).isNotEmpty;
    if (buscaAnteriorAtiva && !_buscaAtiva) {
      _motoristasExpandidos.clear();
    }
  }

  List<_GrupoMotorista> _agruparPorMotorista(List<Cliente> clientes) {
    final agrupado = <String, _GrupoMotorista>{};
    for (final cliente in clientes) {
      final motorista = agrupado.putIfAbsent(
        cliente.idMotoristaResp,
        () => _GrupoMotorista(
          id: cliente.idMotoristaResp,
          nome: cliente.nomeMotoristaResp,
        ),
      );
      motorista.clientes.add(cliente);
    }

    final motoristas = agrupado.values.toList()
      ..sort((a, b) {
        final comparacao = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        return comparacao != 0 ? comparacao : a.id.compareTo(b.id);
      });

    final contagensPorNome = <String, int>{};
    for (final motorista in motoristas) {
      final chaveNome = motorista.nome.toLowerCase();
      contagensPorNome.update(
        chaveNome,
        (contagem) => contagem + 1,
        ifAbsent: () => 1,
      );
    }

    return motoristas.map((motorista) {
      final nomeRepetido = contagensPorNome[motorista.nome.toLowerCase()]! > 1;
      return _GrupoMotorista(
        id: motorista.id,
        nome: motorista.nome,
        rotulo: nomeRepetido
            ? '${motorista.nome} (${motorista.id})'
            : motorista.nome,
        clientes: motorista.clientes,
      );
    }).toList();
  }

  Map<String, List<Cliente>> _agruparPorCidade(List<Cliente> clientes) {
    final agrupado = <String, List<Cliente>>{};
    for (final cliente in clientes) {
      agrupado.putIfAbsent(cliente.endereco.cidade, () => []).add(cliente);
    }
    return agrupado;
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    if (sessionState is! SessionAuthenticated) {
      return const SizedBox.shrink();
    }

    final usuario = sessionState.usuario;
    return BlocProvider(
      create: (_) => getIt<ClientListCubit>()..ouvirClientes(usuario),
      child: BlocBuilder<ClientListCubit, ClientListState>(
        builder: (context, state) {
          if (state is ClientListInitial || state is ClientListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (state is ClientListError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () =>
                        context.read<ClientListCubit>().ouvirClientes(usuario),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is! ClientListLoaded) {
            return const SizedBox.shrink();
          }

          if (state.clientes.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado'));
          }

          final consulta = _normalizarTexto(widget.searchQuery.trim());
          final clientes = consulta.isEmpty
              ? state.clientes
              : state.clientes
                    .where(
                      (cliente) =>
                          _normalizarTexto(cliente.nome).contains(consulta),
                    )
                    .toList();

          if (clientes.isEmpty) {
            return const Center(child: Text('Nenhum cliente encontrado'));
          }

          final motoristas = _agruparPorMotorista(clientes);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: motoristas.map((motorista) {
              final expandido =
                  _buscaAtiva || _motoristasExpandidos.contains(motorista.id);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                clipBehavior: Clip.antiAlias,
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
                              _motoristasExpandidos.remove(motorista.id);
                            } else {
                              _motoristasExpandidos.add(motorista.id);
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
                                Icons.local_shipping,
                                size: 19,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  motorista.rotulo,
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
                                  '${motorista.clientes.length}',
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
                          ? _buildClientesPorCidade(motorista.clientes)
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

  Widget _buildClientesPorCidade(List<Cliente> clientes) {
    final cidades = _agruparPorCidade(clientes).entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (
          var indiceCidade = 0;
          indiceCidade < cidades.length;
          indiceCidade++
        ) ...[
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              cidades[indiceCidade].key,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          for (
            var indiceCliente = 0;
            indiceCliente < cidades[indiceCidade].value.length;
            indiceCliente++
          )
            _buildCardCliente(
              cidades[indiceCidade].value[indiceCliente],
              mostrarDivisor:
                  indiceCidade < cidades.length - 1 ||
                  indiceCliente < cidades[indiceCidade].value.length - 1,
            ),
        ],
      ],
    );
  }

  Widget _buildCardCliente(Cliente cliente, {required bool mostrarDivisor}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.push('/clients/${cliente.id}', extra: cliente);
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.group, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cliente.nome,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                        context.push('/deliveries/new', extra: cliente);
                      },
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(
                          '/clients/${cliente.id}/edit',
                          extra: cliente,
                        );
                      },
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
        if (mostrarDivisor)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color.fromARGB(120, 158, 158, 158),
          ),
      ],
    );
  }
}

class _GrupoMotorista {
  _GrupoMotorista({
    required this.id,
    required this.nome,
    String? rotulo,
    List<Cliente>? clientes,
  }) : rotulo = rotulo ?? nome,
       clientes = clientes ?? [];

  final String id;
  final String nome;
  final String rotulo;
  final List<Cliente> clientes;
}

String _normalizarTexto(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp('[àáâãäåāăą]'), 'a')
      .replaceAll(RegExp('[èéêëēĕėęě]'), 'e')
      .replaceAll(RegExp('[ìíîïĩīĭįı]'), 'i')
      .replaceAll(RegExp('[òóôõöøōŏő]'), 'o')
      .replaceAll(RegExp('[ùúûüũūŭůűų]'), 'u')
      .replaceAll(RegExp('[çćĉċč]'), 'c')
      .replaceAll(RegExp('[ñńņň]'), 'n')
      .replaceAll(RegExp('[ýÿŷ]'), 'y')
      .replaceAll(RegExp('[śŝşš]'), 's')
      .replaceAll(RegExp('[źżž]'), 'z')
      .replaceAll(RegExp('[ŕŗř]'), 'r')
      .replaceAll(RegExp('[ĺļľł]'), 'l')
      .replaceAll(RegExp('[ďđ]'), 'd')
      .replaceAll(RegExp('[ĝğġģ]'), 'g')
      .replaceAll(RegExp('[ĥ]'), 'h')
      .replaceAll(RegExp('[ĵ]'), 'j')
      .replaceAll(RegExp('[ķ]'), 'k')
      .replaceAll(RegExp('[ţť]'), 't')
      .replaceAll(RegExp('[ŵ]'), 'w')
      .replaceAll(RegExp('[æ]'), 'ae')
      .replaceAll(RegExp('[œ]'), 'oe')
      .replaceAll(RegExp('[ß]'), 'ss')
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '');
}
