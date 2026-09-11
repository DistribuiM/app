import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/custom_appbar.dart'; 
import '../../core/widgets/seletor_imagem.dart'; 

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  XFile? _comprovante; 

  void _salvarPagamento() {
    if (_comprovante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, anexe o comprovante de pagamento!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("Imagem pronta para o backend: ${_comprovante!.path}");
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comprovante salvo com sucesso! (Falta o Backend)'),
          backgroundColor: Colors.green,
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Registrar Pagamento'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Anexe o comprovante do pagamento abaixo:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            SeletorImagem(
              onImageSelected: (imagemSelecionada) {
                setState(() {
                  _comprovante = imagemSelecionada;
                });
              },
            ),
            
            const SizedBox(height: 48),
            
            ElevatedButton(
              onPressed: _salvarPagamento,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Finalizar Pagamento', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}