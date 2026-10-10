import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/seletor_imagem.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/dropdown.dart';
import '../../../../core/widgets/input.dart';
import '../../../../core/widgets/segment.dart';
import '../../../../core/widgets/segmented_button.dart';
import '../../../../core/widgets/date_textfield.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../cubit/delivery_form_cubit.dart';
import '../cubit/delivery_form_state.dart';

class DeliveryForm extends StatefulWidget {
  const DeliveryForm({super.key});

  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  final List<Segment> segments = const [
    Segment(value: 0, label: 'Entrega de Milho', icon: Icons.local_shipping),
    Segment(value: 1, label: 'Pagamento', icon: Icons.attach_money),
  ];

  // Controllers
  final _quantidadeController = TextEditingController();
  final _valorPagoController = TextEditingController();
  final _observacaoController = TextEditingController();

  // Campos
  String? _dataEntrega;
  Usuario? _motoristaSelecionado;
  Cliente? _clienteSelecionado;
  int _precoUnitario = 80;
  bool _clientePagou = false;
  int _formaPagamento = 0; // 0=Dinheiro, 1=Pix, 2=Cartão
  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorPagoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryFormCubit>(
      create: (_) => getIt<DeliveryFormCubit>()..carregarDados(),
      child: BlocConsumer<DeliveryFormCubit, DeliveryFormState>(
        listener: (context, state) {
          if (state is DeliveryFormSuccess) {
            context.pop();
          } else if (state is DeliveryFormError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final carregando = state is DeliveryFormLoading;
          final motoristas = state is DeliveryFormLoaded
              ? state.motoristas
              : state is DeliveryFormSubmitting
              ? state.motoristas
              : <Usuario>[];
          final clientes = state is DeliveryFormLoaded
              ? state.clientes
              : state is DeliveryFormSubmitting
              ? state.clientes
              : <Cliente>[];
          final salvando = state is DeliveryFormSubmitting;

          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Cadastro de Entrega',
              leading: true,
            ),
            backgroundColor: const Color(0xFFF7F8F5),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(36),
                child: Column(
                  children: [
                    CustomSegmentedButton(segments: segments),
                    const SizedBox(height: 20),

                    DateTextField(
                      onDateChanged: (data) => setState(() {
                        _dataEntrega = data;
                      }),
                    ),
                    const SizedBox(height: 20),

                    carregando
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          )
                        : Dropdown(
                            options: motoristas.map((m) => m.nome).toList(),
                            hintText: "Motorista*",
                            onChanged: (nome) {
                              final index = motoristas.indexWhere(
                                (m) => m.nome == nome,
                              );
                              setState(
                                () => _motoristaSelecionado = index != -1
                                    ? motoristas[index]
                                    : null,
                              );
                            },
                          ),
                    const SizedBox(height: 20),

                    carregando
                        ? const SizedBox.shrink()
                        : Dropdown(
                            options: clientes
                                .map((c) => "${c.nome} - ${c.endereco.cidade}")
                                .toList(),
                            hintText: "Cliente*",
                            onChanged: (valor) {
                              final index = clientes.indexWhere(
                                (c) =>
                                    "${c.nome} - ${c.endereco.cidade}" == valor,
                              );
                              setState(
                                () => _clienteSelecionado = index != -1
                                    ? clientes[index]
                                    : null,
                              );
                            },
                          ),
                    const SizedBox(height: 20),

                    const Dropdown(
                      options: ["Endereço do cliente", "Galpão", "Feira"],
                      hintText: "Local da Entrega*",
                    ),
                    const SizedBox(height: 20),

                    Input(
                      label: 'Quantidade de Milho*',
                      hintText: '',
                      numberInput: true,
                      controller: _quantidadeController,
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      alignment: Alignment.centerLeft,
                      child: const Text("Preço do Milho*"),
                    ),

                    CustomSegmentedButton(
                      segments: const [
                        Segment(value: 80, label: '80,00'),
                        Segment(value: 90, label: '90,00'),
                      ],
                      onSelectionChanged: (valor) =>
                          setState(() => _precoUnitario = valor),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      alignment: Alignment.centerLeft,
                      child: const Text("Cliente fez algum pagamento?*"),
                    ),

                    CustomSegmentedButton(
                      segments: const [
                        Segment(value: 0, label: 'Não'),
                        Segment(value: 1, label: 'Sim'),
                      ],
                      onSelectionChanged: (valor) =>
                          setState(() => _clientePagou = valor == 1),
                    ),
                    const SizedBox(height: 20),

                    Visibility(
                      visible: _clientePagou,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            alignment: Alignment.centerLeft,
                            child: const Text("Forma de pagamento*"),
                          ),
                          CustomSegmentedButton(
                            segments: const [
                              Segment(value: 0, label: 'Dinheiro'),
                              Segment(value: 1, label: 'Pix'),
                              Segment(value: 2, label: 'Cartão'),
                            ],
                            onSelectionChanged: (valor) => setState(() {
                              _formaPagamento = valor;
                            }),
                          ),
                          const SizedBox(height: 20),

                          Input(
                            label: 'Valor pago*',
                            hintText: '',
                            numberInput: true,
                            controller: _valorPagoController,
                          ),
                          const SizedBox(height: 20),

                          SeletorImagem(
                            onImageSelected: (imagemSelecionada) {
                              print(
                                "Foto capturada com sucesso: ${imagemSelecionada.path}",
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Input(
                      label: 'Observação',
                      hintText: '',
                      controller: _observacaoController,
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
                      : () async {
                          if (_dataEntrega == null ||
                              _motoristaSelecionado == null ||
                              _clienteSelecionado == null ||
                              _quantidadeController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Preencha todos os campos obrigatórios!",
                                ),
                              ),
                            );
                            return;
                          }

                          final quantidade =
                              int.tryParse(_quantidadeController.text) ?? 0;
                          final valorPago = _clientePagou
                              ? (double.tryParse(_valorPagoController.text) ??
                                    0.0)
                              : 0.0;
                          final valorTotal =
                              quantidade * _precoUnitario.toDouble();
                          final valorPendente = valorTotal - valorPago;
                          final formasPagamento = ['Dinheiro', 'Pix', 'Cartão'];

                          await context
                              .read<DeliveryFormCubit>()
                              .registrarEntrega(
                                dataEntrega: _dataEntrega!,
                                idMotorista: _motoristaSelecionado!.id,
                                nomeMotorista: _motoristaSelecionado!.nome,
                                idCliente: _clienteSelecionado!.id,
                                nomeCliente: _clienteSelecionado!.nome,
                                cidadeCliente:
                                    _clienteSelecionado!.endereco.cidade,
                                quantidadeSacos: quantidade,
                                precoUnitario: _precoUnitario.toDouble(),
                                valorPago: valorPago,
                                valorPendente: valorPendente,
                                formaPagamento: _clientePagou
                                    ? formasPagamento[_formaPagamento]
                                    : 'Nenhum',
                                pago: valorPendente <= 0,
                                entregue: true,
                                observacao: _observacaoController.text,
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
