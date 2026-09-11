import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SeletorImagem extends StatefulWidget {
  final Function(XFile) onImageSelected; 

  const SeletorImagem({super.key, required this.onImageSelected});

  @override
  State<SeletorImagem> createState() => _SeletorImagemState();
}

class _SeletorImagemState extends State<SeletorImagem> {
  XFile? _imagemSelecionada; 
  final ImagePicker _picker = ImagePicker();

  Future<void> _escolherImagem() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);
    
    if (imagem != null) {
      setState(() {
        _imagemSelecionada = imagem;
      });
      widget.onImageSelected(_imagemSelecionada!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _imagemSelecionada != null
            ? (kIsWeb 
                ? Image.network(
                    _imagemSelecionada!.path, 
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file( 
                    File(_imagemSelecionada!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ))
            : Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _escolherImagem,
          icon: const Icon(Icons.upload_file),
          label: const Text('Anexar Comprovante'),
        ),
      ],
    );
  }
}