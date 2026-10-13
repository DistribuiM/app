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
import '../cubit/client_form_cubit.dart';
import '../cubit/client_form_state.dart';
import '../cubit/motorista_list_cubit.dart';
import '../cubit/motorista_list_state.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({super.key});

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
            context.pop();
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
            appBar: CustomAppBar(title: 'Cadastro de Cliente', leading: true),
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

                          final responsavel = usuarioLogado.isAdmin
                              ? _responsavelSelecionado!
                              : usuarioLogado;
                          context.read<ClientFormCubit>().registrarCliente(
                            nome: _nomeController.text.trim(),
                            rua: _enderecoController.text.trim(),
                            complemento: _complementoController.text.trim(),
                            cidade: _cidadeSelecionada!,
                            telefone: _telefoneController.text.trim(),
                            idMotoristaResp: responsavel.id,
                            nomeMotoristaResp: responsavel.nome,
                          );
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

class _MotoristaResponsavelField extends StatelessWidget {
  const _MotoristaResponsavelField({required this.onChanged});

  final ValueChanged<Usuario?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MotoristaListCubit>()..carregarMotoristas(),
      child: BlocBuilder<MotoristaListCubit, MotoristaListState>(
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
            onChanged: (rotulo) => onChanged(usuariosPorRotulo[rotulo]),
          );
        },
      ),
    );
  }
}
