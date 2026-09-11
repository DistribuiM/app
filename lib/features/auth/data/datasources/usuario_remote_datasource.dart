import 'package:cloud_firestore/cloud_firestore.dart';

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
        print("AVISO: Já existe um motorista cadastrado com o e-mail $email!");
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

      print("Motorista $nome salvo com sucesso!");
    } catch (erro) {
      print("Erro ao salvar motorista: $erro");
    }
  }

  Future<List<Usuario>> buscarMotoristas() async {
    try {
      final snapshot = await _db.collection('motoristas').get();
      return snapshot.docs.map((doc) {
        return Usuario.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (erro) {
      print("Erro ao buscar motoristas: $erro");
      return [];
    }
  }

  Future<Usuario?> buscarMotoristaPorId(String email) async {
    try {
      final docSnap = await _db.collection('motoristas').doc(email).get();

      if (docSnap.exists) {
        return Usuario.fromMap(docSnap.data()!, docSnap.id);
      }
      return null;
    } catch (erro) {
      print("Erro ao buscar motorista específico: $erro");
      return null;
    }
  }
}
