import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/dropdown.dart';
import '../../../../core/widgets/input.dart';
import '../../../../core/widgets/checkbox.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/cubit/session_state.dart';
import '../../domain/entities/cliente.dart';
import '../cubit/client_form_cubit.dart';
import '../cubit/client_form_state.dart';
import '../cubit/motorista_list_cubit.dart';
import '../cubit/motorista_list_state.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final List<String> _cities = [
    'Santos',
    'São Vicente',
    'Guarujá',
    'Praia Grande',
    'Cubatão',
    'Bertioga',
    'Mongaguá',
    'Itanhaém',
  ];

  // Controllers para pegar o texto de cada campo
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _complementoController = TextEditingController();
  String? _cidadeSelecionada;
  Usuario? _responsavelSelecionado;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    if (cliente != null) {
      _nomeController.text = cliente.nome;
      _enderecoController.text = cliente.endereco.rua;
      _telefoneController.text = cliente.telefone;
      _complementoController.text = cliente.endereco.complemento;
      if (_cities.contains(cliente.endereco.cidade)) {
        _cidadeSelecionada = cliente.endereco.cidade;
      }
    }
  }

  @override
  // Limpa os controllers
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClientFormCubit>(),
      child: BlocConsumer<ClientFormCubit, ClientFormState>(
        listener: (context, state) {
          if (state is ClientFormSuccess) {
            context.pop(true);
          } else if (state is ClientFormError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final salvando = state is ClientFormSubmitting;
          final sessionState = context.watch<SessionCubit>().state;
          final isAdmin =
              sessionState is SessionAuthenticated &&
              sessionState.usuario.isAdmin;

          return Scaffold(
            appBar: CustomAppBar(
              title: widget.cliente == null
                  ? 'Cadastro de Cliente'
                  : 'Editar Cliente',
              leading: true,
            ),
            backgroundColor: const Color(0xFFF7F8F5),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(36),
                child: Column(
                  children: [
                    Input(
                      label: 'Nome*',
                      hintText: 'Digite o nome do cliente',
                      controller: _nomeController,
                    ),
                    const SizedBox(height: 20),
                    Input(
                      label: 'Endereço*',
                      hintText: 'Digite o endereço do cliente',
                      controller: _enderecoController,
                    ),
                    const SizedBox(height: 20),
                    Dropdown(
                      options: _cities,
                      hintText: 'Cidade*',
                      initialSelection: _cidadeSelecionada,
                      onChanged: (valor) {
                        setState(() => _cidadeSelecionada = valor);
                        debugPrint('Cidade selecionada: $valor');
                      },
                    ),
                    const SizedBox(height: 20),
                    Input(
                      label: 'Telefone*',
                      hintText: 'Digite o telefone do cliente',
                      controller: _telefoneController,
                    ),
                    const SizedBox(height: 20),
                    Input(
                      label: 'Complemento ou ponto de referência',
                      hintText:
                          'Digite o complemento ou ponto de referência do cliente',
                      controller: _complementoController,
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 20),
                      _MotoristaResponsavelField(
                        idResponsavelAtual:
                            widget.cliente?.idMotoristaResp,
                        onChanged: (usuario) {
                          setState(() => _responsavelSelecionado = usuario);
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    CheckBox(
                      label: "Permitir vendas a prazo para este cliente?",
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: const Color(0xFF4D7C42),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: salvando
                      ? null
                      : () {
                          final currentSessionState = context
                              .read<SessionCubit>()
                              .state;
                          final usuarioLogado =
                              currentSessionState is SessionAuthenticated
                                  ? currentSessionState.usuario
                                  : null;
                          final isAdminLogado =
                              usuarioLogado?.isAdmin ?? false;

                          if (_nomeController.text.isEmpty ||
                              _telefoneController.text.isEmpty ||
                              _enderecoController.text.isEmpty ||
                              _cidadeSelecionada == null ||
                              (isAdminLogado &&
                                  _responsavelSelecionado == null)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Preencha todos os campos obrigatórios! (*)",
                                ),
                              ),
                            );
                            return;
                          }

                          if (usuarioLogado == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sessão inválida. Faça login novamente.',
                                ),
                              ),
                            );
                            return;
                          }

                          final nome = _nomeController.text.trim();
                          final rua = _enderecoController.text.trim();
                          final complemento =
                              _complementoController.text.trim();
                          final cidade = _cidadeSelecionada!;
                          final telefone = _telefoneController.text.trim();
                          final cubit = context.read<ClientFormCubit>();

                          if (widget.cliente == null) {
                            final responsavel = usuarioLogado.isAdmin
                                ? _responsavelSelecionado!
                                : usuarioLogado;
                            cubit.registrarCliente(
                              nome: nome,
                              rua: rua,
                              complemento: complemento,
                              cidade: cidade,
                              telefone: telefone,
                              idMotoristaResp: responsavel.id,
                              nomeMotoristaResp: responsavel.nome,
                            );
                          } else {
                            cubit.atualizarCliente(
                              id: widget.cliente!.id,
                              nome: nome,
                              rua: rua,
                              complemento: complemento,
                              cidade: cidade,
                              telefone: telefone,
                              idMotoristaResp: usuarioLogado.isAdmin
                                  ? _responsavelSelecionado!.id
                                  : null,
                              nomeMotoristaResp: usuarioLogado.isAdmin
                                  ? _responsavelSelecionado!.nome
                                  : null,
                            );
                          }
                        },
                  child: salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Salvar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MotoristaResponsavelField extends StatefulWidget {
  const _MotoristaResponsavelField({
    required this.idResponsavelAtual,
    required this.onChanged,
  });

  final String? idResponsavelAtual;
  final ValueChanged<Usuario?> onChanged;

  @override
  State<_MotoristaResponsavelField> createState() =>
      _MotoristaResponsavelFieldState();
}

class _MotoristaResponsavelFieldState
    extends State<_MotoristaResponsavelField> {
  String? _initialSelection;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MotoristaListCubit>()..carregarMotoristas(),
      child: BlocConsumer<MotoristaListCubit, MotoristaListState>(
        listenWhen: (previous, current) =>
            current is MotoristaListLoaded &&
            previous is! MotoristaListLoaded,
        listener: (context, state) {
          if (state is! MotoristaListLoaded) {
            return;
          }
          final idResponsavelAtual = widget.idResponsavelAtual;
          if (idResponsavelAtual == null) {
            return;
          }
          for (final motorista in state.motoristas) {
            if (motorista.id == idResponsavelAtual) {
              final nomeContagens = <String, int>{};
              for (final item in state.motoristas) {
                nomeContagens.update(
                  item.nome,
                  (contagem) => contagem + 1,
                  ifAbsent: () => 1,
                );
              }
              final rotulo = nomeContagens[motorista.nome]! > 1
                  ? '${motorista.nome} (${motorista.email})'
                  : motorista.nome;
              setState(() => _initialSelection = rotulo);
              widget.onChanged(motorista);
              return;
            }
          }
        },
        builder: (context, state) {
          if (state is MotoristaListInitial ||
              state is MotoristaListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MotoristaListError) {
            return Column(
              children: [
                Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<MotoristaListCubit>().carregarMotoristas(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            );
          }

          if (state is! MotoristaListLoaded) {
            return const SizedBox.shrink();
          }

          final nomeContagens = <String, int>{};
          for (final motorista in state.motoristas) {
            nomeContagens.update(
              motorista.nome,
              (contagem) => contagem + 1,
              ifAbsent: () => 1,
            );
          }

          final usuariosPorRotulo = <String, Usuario>{};
          for (final motorista in state.motoristas) {
            final rotulo = nomeContagens[motorista.nome]! > 1
                ? '${motorista.nome} (${motorista.email})'
                : motorista.nome;
            usuariosPorRotulo[rotulo] = motorista;
          }

          return Dropdown(
            options: usuariosPorRotulo.keys.toList(),
            hintText: 'Motorista responsável*',
            initialSelection: _initialSelection,
            onChanged: (rotulo) =>
                widget.onChanged(usuariosPorRotulo[rotulo]),
          );
        },
      ),
    );
  }
}
