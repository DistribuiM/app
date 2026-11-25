import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/utils/contact_launcher.dart';
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
    final valorPendente = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(cliente.saldoPendente);
    final mensagemCobranca =
        'Olá, ${cliente.nome}! Tudo bem? Passando para lembrar que consta '
        'um saldo pendente de $valorPendente. Quando puder, poderia verificar, '
        'por favor? Agradecemos!';

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
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.green[700], size: 28),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "R\$${cliente.saldoPendente.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Enviar cobrança pelo WhatsApp',
                    onPressed: () => runContactAction(
                      context,
                      () => openWhatsApp(
                        cliente.telefone,
                        message: mensagemCobranca,
                      ),
                    ),
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Transform.translate(
                              offset: const Offset(0, -1.5),
                              child: const Text(
                                '\$',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              Text(
                "${endereco.rua}${endereco.complemento.isNotEmpty ? ', ${endereco.complemento}' : ''}",
                style: const TextStyle(fontSize: 16),
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
                  Expanded(
                    child: Text(
                      cliente.telefone,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Ligar para ${cliente.nome}',
                        onPressed: () => runContactAction(
                          context,
                          () => openPhoneCall(cliente.telefone),
                        ),
                        icon: Icon(Icons.phone, color: Colors.grey[600]),
                      ),
                      IconButton(
                        tooltip: 'Abrir WhatsApp de ${cliente.nome}',
                        onPressed: () => runContactAction(
                          context,
                          () => openWhatsApp(cliente.telefone),
                        ),
                        icon: Icon(Icons.chat_bubble, color: Colors.grey[600]),
                      ),
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
