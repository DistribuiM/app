import 'package:flutter/material.dart';

import '../models/cliente_filtro.dart';

class FiltroClientesSheet extends StatefulWidget {
  const FiltroClientesSheet({
    super.key,
    required this.filtroAtual,
    required this.cidades,
    required this.motoristas,
  });

  final ClienteFiltro filtroAtual;
  final List<String> cidades;
  // id do motorista -> nome. Vazio para quem não é admin, para esconder o campo
  final Map<String, String> motoristas;

  @override
  State<FiltroClientesSheet> createState() => _FiltroClientesSheetState();
}

class _FiltroClientesSheetState extends State<FiltroClientesSheet> {
  String? _cidade;
  String? _idMotorista;
  bool? _permiteVendasAPrazo;

  @override
  void initState() {
    super.initState();
    _cidade = widget.filtroAtual.cidade;
    _idMotorista = widget.filtroAtual.idMotorista;
    _permiteVendasAPrazo = widget.filtroAtual.permiteVendasAPrazo;
  }

  Widget _campo<T>({
    required String rotulo,
    required T? valor,
    required List<DropdownMenuItem<T?>> itens,
    required ValueChanged<T?> aoMudar,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: rotulo,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: valor,
          isExpanded: true,
          items: itens,
          onChanged: aoMudar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _campo<String>(
              rotulo: 'Cidade',
              valor: _cidade,
              itens: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todas'),
                ),
                ...widget.cidades.map(
                  (cidade) => DropdownMenuItem<String?>(
                    value: cidade,
                    child: Text(cidade),
                  ),
                ),
              ],
              aoMudar: (valor) => setState(() => _cidade = valor),
            ),
            if (widget.motoristas.isNotEmpty) ...[
              const SizedBox(height: 12),
              _campo<String>(
                rotulo: 'Motorista responsável',
                valor: _idMotorista,
                itens: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos'),
                  ),
                  ...widget.motoristas.entries.map(
                    (entrada) => DropdownMenuItem<String?>(
                      value: entrada.key,
                      child: Text(entrada.value),
                    ),
                  ),
                ],
                aoMudar: (valor) => setState(() => _idMotorista = valor),
              ),
            ],
            const SizedBox(height: 12),
            _campo<bool>(
              rotulo: 'Venda a prazo',
              valor: _permiteVendasAPrazo,
              itens: const [
                DropdownMenuItem<bool?>(value: null, child: Text('Todos')),
                DropdownMenuItem<bool?>(value: true, child: Text('Permite')),
                DropdownMenuItem<bool?>(value: false, child: Text('Não permite')),
              ],
              aoMudar: (valor) => setState(() => _permiteVendasAPrazo = valor),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, const ClienteFiltro()),
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                      ClienteFiltro(
                        cidade: _cidade,
                        idMotorista: _idMotorista,
                        permiteVendasAPrazo: _permiteVendasAPrazo,
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}