import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../domain/entities/cliente.dart';
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

    return Scaffold(
      appBar: const CustomAppBar(title: 'Ficha do Cliente', leading: true),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.green[700], size: 28),
                      const SizedBox(width: 8),
                      Text(
                        cliente.nome,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {}, // abrir formulário de entrega
                    icon: Icon(Icons.add, color: Colors.green[700], size: 28),
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
                  Text(cliente.telefone, style: const TextStyle(fontSize: 16)),
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

              ClientDeliveriesSection(idCliente: cliente.id),
            ],
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
