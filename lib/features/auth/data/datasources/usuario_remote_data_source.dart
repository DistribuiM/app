import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/usuario.dart';

class UsuarioRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarMotorista({
    required String nome,
    required String telefone,
    required String email,
  }) async {
    try {
      final docRef = _db.collection('motoristas').doc(email);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        debugPrint("AVISO: Já existe um motorista cadastrado com o e-mail $email!");
        return;
      }

      await docRef.set({
        "nome": nome,
        "telefone": telefone,
        "email": email,
        "stats": {
          "clientesAtivos": 0,
          "entregasHoje": 0,
          "valorReceber": 0.0
        }
      });

      debugPrint("Motorista $nome salvo com sucesso!");
    } catch (erro) {
      debugPrint("Erro ao salvar motorista: $erro");
    }
  }

  Future<List<Usuario>> buscarMotoristas() async {
    final snapshot = await _db.collection('motoristas').get();
    return snapshot.docs.map((doc) {
      return Usuario.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<Usuario?> buscarMotoristaPorId(String email) async {
    final docSnap = await _db.collection('motoristas').doc(email).get();

    if (docSnap.exists) {
      return Usuario.fromMap(docSnap.data()!, docSnap.id);
    }
    return null;
  }
}
