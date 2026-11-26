import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/date_textfield.dart';
import '../../../../core/widgets/dropdown.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/entities/filtros_entrega.dart';
import '../../../payments/domain/entities/pagamento.dart';

class DeliveryFiltersSheet extends StatefulWidget {
  const DeliveryFiltersSheet({
    super.key,
    required this.entregas,
    this.pagamentos = const [],
    this.clientes = const {},
    required this.filtrosIniciais,
    required this.onApply,
  });

  final List<Entrega> entregas;
  final List<Pagamento> pagamentos;
  final Map<String, Cliente> clientes;
  final FiltrosEntrega filtrosIniciais;
  final ValueChanged<FiltrosEntrega> onApply;

  @override
  State<DeliveryFiltersSheet> createState() => _DeliveryFiltersSheetState();
}

class _DeliveryFiltersSheetState extends State<DeliveryFiltersSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantidadeMinimaController;
  late final TextEditingController _quantidadeMaximaController;
  late final TextEditingController _valorPagoMinimoController;
  late final TextEditingController _valorPagoMaximoController;

  late String? _dataInicial;
  late String? _dataFinal;
  late String? _idMotorista;
  late String? _idCliente;
  late String? _formaPagamento;
  late TipoFormularioEntrega? _tipoFormulario;
  late String? _cidade;
  String? _erroPeriodo;

  @override
  void initState() {
    super.initState();
    final filtros = widget.filtrosIniciais;
    _dataInicial = _formatarData(filtros.dataInicial);
    _dataFinal = _formatarData(filtros.dataFinal);
    _idMotorista = filtros.idMotorista;
    _idCliente = filtros.idCliente;
    _formaPagamento = filtros.formaPagamento;
    _tipoFormulario = filtros.tipoFormulario;
    _cidade = filtros.cidade;
    _quantidadeMinimaController = TextEditingController(
      text: filtros.quantidadeMinima?.toString() ?? '',
    );
    _quantidadeMaximaController = TextEditingController(
      text: filtros.quantidadeMaxima?.toString() ?? '',
    );
    _valorPagoMinimoController = TextEditingController(
      text: filtros.valorPagoMinimo?.toString() ?? '',
    );
    _valorPagoMaximoController = TextEditingController(
      text: filtros.valorPagoMaximo?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _quantidadeMinimaController.dispose();
    _quantidadeMaximaController.dispose();
    _valorPagoMinimoController.dispose();
    _valorPagoMaximoController.dispose();
    super.dispose();
  }

  String? _formatarData(DateTime? data) =>
      data == null ? null : DateFormat('dd/MM/yyyy').format(data);

  DateTime? _parseData(String? data) {
    if (data == null || data.isEmpty) return null;
    return DateFormat('dd/MM/yyyy').parseStrict(data);
  }

  double? _parseValor(String valor) {
    final normalizado = valor.trim().replaceAll(',', '.');
    return normalizado.isEmpty ? null : double.tryParse(normalizado);
  }

  Map<String, String?> get _opcoesMotoristas {
    final nomesPorId = <String, String>{};
    for (final entrega in widget.entregas) {
      nomesPorId.putIfAbsent(entrega.idMotorista, () => entrega.nomeMotorista);
    }
    for (final pagamento in widget.pagamentos) {
      nomesPorId.putIfAbsent(
        pagamento.idMotorista,
        () => pagamento.nomeMotorista,
      );
    }

    final contagemPorNome = <String, int>{};
    for (final nome in nomesPorId.values) {
      final chave = nome.toLowerCase();
      contagemPorNome.update(
        chave,
        (quantidade) => quantidade + 1,
        ifAbsent: () => 1,
      );
    }

    final opcoes = <String, String?>{'Todos': null};
    for (final entry in nomesPorId.entries) {
      final nome = entry.value;
      final repetido = contagemPorNome[nome.toLowerCase()]! > 1;
      opcoes[repetido ? '$nome (${entry.key})' : nome] = entry.key;
    }
    return opcoes;
  }

  Map<String, String?> get _opcoesClientes {
    final dadosPorId = <String, (String, String)>{};
    for (final entrega in widget.entregas) {
      final cliente = widget.clientes[entrega.idCliente];
      dadosPorId.putIfAbsent(
        entrega.idCliente,
        () => (
          cliente?.nome ?? entrega.nomeCliente,
          cliente?.endereco.cidade ?? entrega.cidadeCliente,
        ),
      );
    }
    for (final pagamento in widget.pagamentos) {
      final cliente = widget.clientes[pagamento.idCliente];
      dadosPorId.putIfAbsent(
        pagamento.idCliente,
        () => (
          cliente?.nome ?? pagamento.nomeCliente,
          cliente?.endereco.cidade ?? pagamento.cidadeCliente,
        ),
      );
    }

    final rotulos = <String, int>{};
    for (final dados in dadosPorId.values) {
      final base = '${dados.$1} - ${dados.$2}';
      rotulos.update(base, (quantidade) => quantidade + 1, ifAbsent: () => 1);
    }

    final opcoes = <String, String?>{'Todos': null};
    for (final entry in dadosPorId.entries) {
      final base = '${entry.value.$1} - ${entry.value.$2}';
      final rotulo = rotulos[base]! > 1 ? '$base #${entry.key}' : base;
      opcoes[rotulo] = entry.key;
    }
    return opcoes;
  }

  Map<String, String?> _opcoesTexto(
    Iterable<String> valores, {
    String todos = 'Todas',
  }) {
    final opcoes = <String, String?>{todos: null};
    for (final valor in valores.toSet().toList()..sort()) {
      if (valor.isNotEmpty) opcoes[valor] = valor;
    }
    return opcoes;
  }

  String? _rotuloSelecionado(Map<String, String?> opcoes, String? valor) {
    for (final opcao in opcoes.entries) {
      if (opcao.value == valor) return opcao.key;
    }
    return null;
  }

  bool _validarIntervalos() {
    if (!_formKey.currentState!.validate()) return false;
    final dataInicial = _parseData(_dataInicial);
    final dataFinal = _parseData(_dataFinal);
    if (dataInicial != null &&
        dataFinal != null &&
        dataInicial.isAfter(dataFinal)) {
      setState(() => _erroPeriodo = 'A data inicial deve vir antes da final.');
      return false;
    }
    setState(() => _erroPeriodo = null);
    return true;
  }

  String? _validarInteiro(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final numero = int.tryParse(valor.trim());
    if (numero == null || numero < 0) {
      return 'Informe um número inteiro válido.';
    }
    return null;
  }

  String? _validarDecimal(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final numero = _parseValor(valor);
    if (numero == null || numero < 0) return 'Informe um valor válido.';
    return null;
  }

  bool _intervaloNumericoValido(
    String minimo,
    String maximo,
    num Function(String) parse,
  ) {
    if (minimo.trim().isEmpty || maximo.trim().isEmpty) return true;
    return parse(minimo) <= parse(maximo);
  }

  String? _validarQuantidade(String? _) {
    if (_validarInteiro(_quantidadeMinimaController.text) != null ||
        _validarInteiro(_quantidadeMaximaController.text) != null) {
      return null;
    }
    if (!_intervaloNumericoValido(
      _quantidadeMinimaController.text,
      _quantidadeMaximaController.text,
      (valor) => int.parse(valor.trim()),
    )) {
      return 'O mínimo não pode ser maior que o máximo.';
    }
    return null;
  }

  String? _validarValorPago(String? _) {
    if (_validarDecimal(_valorPagoMinimoController.text) != null ||
        _validarDecimal(_valorPagoMaximoController.text) != null) {
      return null;
    }
    if (!_intervaloNumericoValido(
      _valorPagoMinimoController.text,
      _valorPagoMaximoController.text,
      (valor) => _parseValor(valor)!,
    )) {
      return 'O mínimo não pode ser maior que o máximo.';
    }
    return null;
  }

  void _aplicar() {
    if (!_validarIntervalos()) return;

    widget.onApply(
      FiltrosEntrega(
        dataInicial: _parseData(_dataInicial),
        dataFinal: _parseData(_dataFinal),
        idMotorista: _idMotorista,
        idCliente: _idCliente,
        formaPagamento: _formaPagamento,
        tipoFormulario: _tipoFormulario,
        cidade: _cidade,
        quantidadeMinima: int.tryParse(_quantidadeMinimaController.text.trim()),
        quantidadeMaxima: int.tryParse(_quantidadeMaximaController.text.trim()),
        valorPagoMinimo: _parseValor(_valorPagoMinimoController.text),
        valorPagoMaximo: _parseValor(_valorPagoMaximoController.text),
      ),
    );
    context.pop();
  }

  void _limpar() {
    widget.onApply(const FiltrosEntrega());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final motoristas = _opcoesMotoristas;
    final clientes = _opcoesClientes;
    final formasPagamento = _opcoesTexto([
      ...widget.entregas.map((entrega) => entrega.formaPagamento),
      ...widget.pagamentos.map((pagamento) => pagamento.formaPagamento),
    ]);
    final cidades = _opcoesTexto([
      ...widget.entregas.map(
        (entrega) =>
            widget.clientes[entrega.idCliente]?.endereco.cidade ??
            entrega.cidadeCliente,
      ),
      ...widget.pagamentos.map(
        (pagamento) =>
            widget.clientes[pagamento.idCliente]?.endereco.cidade ??
            pagamento.cidadeCliente,
      ),
    ]);
    final tiposFormulario = <String, TipoFormularioEntrega?>{
      'Todos': null,
      'Entrega': TipoFormularioEntrega.entrega,
      'Pagamento': TipoFormularioEntrega.pagamento,
    };

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filtrar entregas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar filtros',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Data inicial'),
                                DateTextField(
                                  initialDate: _dataInicial,
                                  onDateChanged: (data) => setState(() {
                                    _dataInicial = data;
                                    _erroPeriodo = null;
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Data final'),
                                DateTextField(
                                  initialDate: _dataFinal,
                                  onDateChanged: (data) => setState(() {
                                    _dataFinal = data;
                                    _erroPeriodo = null;
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_erroPeriodo != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _erroPeriodo!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      _CampoSelecao(
                        titulo: 'Motorista',
                        child: Dropdown(
                          options: motoristas.keys.toList(),
                          hintText: 'Selecione',
                          initialSelection: _rotuloSelecionado(
                            motoristas,
                            _idMotorista,
                          ),
                          onChanged: (rotulo) =>
                              setState(() => _idMotorista = motoristas[rotulo]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CampoSelecao(
                        titulo: 'Cliente',
                        child: Dropdown(
                          options: clientes.keys.toList(),
                          hintText: 'Selecione',
                          initialSelection: _rotuloSelecionado(
                            clientes,
                            _idCliente,
                          ),
                          onChanged: (rotulo) =>
                              setState(() => _idCliente = clientes[rotulo]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CampoSelecao(
                        titulo: 'Forma de pagamento',
                        child: Dropdown(
                          options: formasPagamento.keys.toList(),
                          hintText: 'Selecione',
                          initialSelection: _rotuloSelecionado(
                            formasPagamento,
                            _formaPagamento,
                          ),
                          onChanged: (rotulo) => setState(
                            () => _formaPagamento = formasPagamento[rotulo],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CampoSelecao(
                        titulo: 'Tipo de formulário',
                        child: Dropdown(
                          options: tiposFormulario.keys.toList(),
                          hintText: 'Selecione',
                          initialSelection: _rotuloTipoSelecionado(
                            tiposFormulario,
                          ),
                          onChanged: (rotulo) => setState(
                            () => _tipoFormulario = tiposFormulario[rotulo],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CampoSelecao(
                        titulo: 'Cidade da entrega',
                        child: Dropdown(
                          options: cidades.keys.toList(),
                          hintText: 'Selecione',
                          initialSelection: _rotuloSelecionado(
                            cidades,
                            _cidade,
                          ),
                          onChanged: (rotulo) =>
                              setState(() => _cidade = cidades[rotulo]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CampoIntervalo(
                        titulo: 'Quantidade de sacos',
                        minimoController: _quantidadeMinimaController,
                        maximoController: _quantidadeMaximaController,
                        minimoLabel: 'Mínimo',
                        maximoLabel: 'Máximo',
                        teclado: TextInputType.number,
                        validatorCampo: _validarInteiro,
                        validatorIntervalo: _validarQuantidade,
                      ),
                      const SizedBox(height: 12),
                      _CampoIntervalo(
                        titulo: 'Valor pago',
                        minimoController: _valorPagoMinimoController,
                        maximoController: _valorPagoMaximoController,
                        minimoLabel: 'Mínimo',
                        maximoLabel: 'Máximo',
                        teclado: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validatorCampo: _validarDecimal,
                        validatorIntervalo: _validarValorPago,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _limpar,
                    child: const Text('Limpar filtros'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _aplicar,
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _rotuloTipoSelecionado(Map<String, TipoFormularioEntrega?> opcoes) {
    for (final opcao in opcoes.entries) {
      if (opcao.value == _tipoFormulario) return opcao.key;
    }
    return null;
  }
}

class _CampoSelecao extends StatelessWidget {
  const _CampoSelecao({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _CampoIntervalo extends StatelessWidget {
  const _CampoIntervalo({
    required this.titulo,
    required this.minimoController,
    required this.maximoController,
    required this.minimoLabel,
    required this.maximoLabel,
    required this.teclado,
    required this.validatorCampo,
    required this.validatorIntervalo,
  });

  final String titulo;
  final TextEditingController minimoController;
  final TextEditingController maximoController;
  final String minimoLabel;
  final String maximoLabel;
  final TextInputType teclado;
  final FormFieldValidator<String> validatorCampo;
  final FormFieldValidator<String> validatorIntervalo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: minimoController,
                keyboardType: teclado,
                validator: validatorCampo,
                decoration: InputDecoration(labelText: minimoLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: maximoController,
                keyboardType: teclado,
                validator: validatorCampo,
                decoration: InputDecoration(labelText: maximoLabel),
              ),
            ),
          ],
        ),
        FormField<String>(
          validator: validatorIntervalo,
          builder: (state) => state.hasError
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
