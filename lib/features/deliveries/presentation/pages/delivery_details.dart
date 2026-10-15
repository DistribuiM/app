import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_appbar.dart';
import '../../domain/entities/entrega.dart';

class EntregaPage extends StatelessWidget {
  const EntregaPage({super.key, required this.entrega});

  final Entrega entrega;

  @override
  Widget build(BuildContext context) {
    final corPagamento = entrega.pago ? Colors.green[700] : Colors.red[700];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: const CustomAppBar(title: 'Detalhe da Entrega', leading: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label(text: 'Cliente'),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.green[700], size: 28),
                  const SizedBox(width: 8),
                  Text(
                    entrega.nomeCliente,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Cidade'),
              Text(entrega.cidadeCliente, style: const TextStyle(fontSize: 16)),
              const Divider(),
              const SizedBox(height: 12),
              const _Label(text: 'Data da Entrega'),
              Text(entrega.dataEntrega, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const _Label(text: 'Motorista'),
              Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    entrega.nomeMotorista,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Quantidade de Sacos'),
              Text(
                '${entrega.quantidadeSacos}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Preço Unitário'),
              Text(
                'R\$${entrega.precoUnitario.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Valor Total'),
              Text(
                'R\$${entrega.valorTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              const _Label(text: 'Forma de Pagamento'),
              Text(
                entrega.formaPagamento,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Valor Pago'),
              Text(
                'R\$${entrega.valorPago.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: corPagamento),
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Valor Pendente'),
              Text(
                'R\$${entrega.valorPendente.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: corPagamento,
                ),
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Situação do Pagamento'),
              Text(
                entrega.pago ? 'Pago' : 'Pendente',
                style: TextStyle(fontSize: 16, color: corPagamento),
              ),
              const SizedBox(height: 20),
              const _Label(text: 'Situação da Entrega'),
              Text(
                entrega.entregue ? 'Entregue' : 'Não entregue',
                style: const TextStyle(fontSize: 16),
              ),
              if (entrega.observacao.trim().isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 12),
                const _Label(text: 'Observação'),
                Text(entrega.observacao, style: const TextStyle(fontSize: 16)),
              ],
            ],
          ),
        ),
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
