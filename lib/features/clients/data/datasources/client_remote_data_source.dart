import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cliente.dart';

class ClientRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarCliente({
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    required String idMotoristaResp,
    required String nomeMotoristaResp,
  }) async {
    // Telefone é único, se já ta registrado, não cria outro
    final query = await _db
      .collection('clientes')
      .where('telefone', isEqualTo: telefone)
      .limit(1)
      .get();

    if (query.docs.isNotEmpty) {
      throw ValidationFailure(
        'Já existe um cliente cadastrado com o telefone $telefone.',
      );
    }

    final docRef = _db.collection('clientes').doc();

    // Se não existe, cria o documento normalmente
    await docRef.set({
      "id": docRef.id,
      "nome": nome,
      "endereco": {
        "rua": rua,
        "complemento": complemento,
        "cidade": cidade,
      },
      "telefone": telefone,
      "motoristaResponsavel": {
        "id": idMotoristaResp,
        "nome": nomeMotoristaResp,
      },
      "financeiro": {
        "saldoPendente": 0.0,
        "totalComprado": 0.0,
        "ultimaEntrega": "", // Fica vazio até a primeira compra
      },
      "ultimasEntregas": [] // Array de histórico
    });

    debugPrint("SUCESSO: Cliente $nome salvo no banco de dados!");
  }

  Future<void> atualizarCliente({
    required String id,
    required String nome,
    required String rua,
    required String complemento,
    required String cidade,
    required String telefone,
    String? idMotoristaResp,
    String? nomeMotoristaResp,
  }) async {
    final query = await _db
        .collection('clientes')
        .where('telefone', isEqualTo: telefone)
        .limit(2)
        .get();

    if (query.docs.any((doc) => doc.id != id)) {
      throw ValidationFailure(
        'Já existe um cliente cadastrado com o telefone $telefone.',
      );
    }

    final dados = <String, dynamic>{
      'nome': nome,
      'telefone': telefone,
      'endereco.rua': rua,
      'endereco.complemento': complemento,
      'endereco.cidade': cidade,
    };
    if (idMotoristaResp != null && nomeMotoristaResp != null) {
      dados['motoristaResponsavel.id'] = idMotoristaResp;
      dados['motoristaResponsavel.nome'] = nomeMotoristaResp;
    }

    await _db.collection('clientes').doc(id).update(dados);
  }

  // Retorna a lista com todos os clientes
  Future<List<Cliente>> buscarClientes({String? idMotorista}) async {
    final clientes = _db.collection('clientes');
    final querySnapshot = idMotorista == null
        ? await clientes.get()
        : await clientes
            .where('motoristaResponsavel.id', isEqualTo: idMotorista)
            .get();

    return querySnapshot.docs.map((doc) {
      return Cliente.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // Procura por id
  Future<Map<String, dynamic>?> buscarClientePorId(String id) async {
    try {
      final doc = await _db.collection('clientes').doc(id).get();
      
      if (doc.exists) {
          final dados = doc.data()!;
          dados['id'] = doc.id;
          return dados;
      }
      return null; 
    } catch (erro) {
      debugPrint("Erro ao buscar cliente específico: $erro");
      return null;
    }
  }

  Future<Map<String, dynamic>?> buscarClientePorTelefone(String telefone) 
  async {
    final query = await _db
        .collection('clientes')
        .where('telefone', isEqualTo: telefone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }

    return null;
  }

}