import 'package:flutter/material.dart';
import '../../core/widgets/custom_appbar.dart';
import '../../core/widgets/dropdown.dart';
import '../../core/widgets/input.dart';
import '../../core/widgets/checkbox.dart';
import 'client_repository.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({super.key});

  @override  
  State<ClientForm> createState() => _ClientFormState();    
}
class _ClientFormState extends State<ClientForm> {
  final List <String> _cities = ['Santos', 'São Vicente', 'Guarujá', 'Praia Grande', 'Cubatão', 'Bertioga', 'Mongaguá', 'Itanhaém'];
  final ClientRepository _service = ClientRepository();

  // Controllers para pegar o texto de cada campo
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _complementoController = TextEditingController();
  String? _cidadeSelecionada;
  bool _salvando = false; 

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
    return Scaffold(
      appBar: CustomAppBar(title: 'Cadastro de Cliente', leading: true),
      backgroundColor: const Color(0xFFF7F8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(36),
          child: Column(
            children: [
              Input(label: 'Nome*', hintText: 'Digite o nome do cliente', controller: _nomeController),
              const SizedBox(height: 20),
              Input(label: 'Endereço*', hintText: 'Digite o endereço do cliente', controller: _enderecoController),
              const SizedBox(height: 20),
              Dropdown(options: _cities, hintText: 'Cidade*', onChanged: (valor) {setState(() => _cidadeSelecionada = valor); print('Cidade selecionada: $valor');}),
              const SizedBox(height: 20),
              Input(label: 'Telefone*', hintText: 'Digite o telefone do cliente', controller: _telefoneController),
              const SizedBox(height: 20),
              Input(label: 'Complemento ou ponto de referência', hintText: 'Digite o complemento ou ponto de referência do cliente', controller: _complementoController),
              const SizedBox(height: 20),
              CheckBox(label: "Permitir vendas a prazo para este cliente?")
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
            onPressed: _salvando ? null : () async {
              if (_nomeController.text.isEmpty || _telefoneController.text.isEmpty || _enderecoController.text.isEmpty || _cidadeSelecionada == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preencha todos os campos obrigatórios! (*)"))
                );
                return;
              }

              setState(() {
                _salvando = true;
              });
              
              await _service.registrarCliente(
                nome: _nomeController.text.trim(),
                rua: _enderecoController.text.trim(),
                complemento: _complementoController.text.trim(),
                cidade: _cidadeSelecionada!,
                telefone: _telefoneController.text.trim(),
                idMotoristaResp: 'id_fixo_por_enquanto',
                nomeMotoristaResp: 'nome_fixo_por_enquanto',
              );

              setState(() {
                _salvando = false;
              });

              if (context.mounted) Navigator.pop(context);
              
            },
            child: _salvando
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Salvar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
          ),
        )
      ),
    );
  }
}