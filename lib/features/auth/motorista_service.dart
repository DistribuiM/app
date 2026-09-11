import 'package:cloud_firestore/cloud_firestore.dart';
import 'usuario.dart';

class MotoristaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarMotorista({
    required String nome,
    required String telefone,
    required String email,
  }) async {
    try {
      // O email é único, se já ta registrado, não registra motorista novo
      final docRef = _db.collection('motoristas').doc(email);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        // Se já existe, a criação é bloqueada
        print("AVISO: Já existe um motorista cadastrado com o e-mail $email!");
        return;
      }

      // Se não existe, o documento é criado normalmente
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
      
      print("Motorista $nome salvo com sucesso!"); // Para Debug
    } catch (erro) {
      print("Erro ao salvar motorista: $erro"); // Para Debug
    }
  }

  // Retorna uma lista de todos os motoristas já como objetos Usuario
  Future<List<Usuario>> buscarMotoristas() async {
    try {
      final snapshot = await _db.collection('motoristas').get();
      return snapshot.docs.map((doc) {
        // Usamos o fromMap da sua classe para instanciar o objeto!
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
        // Retorna o objeto
        return Usuario.fromMap(docSnap.data()!, docSnap.id);
      }
      return null; // Retorna nulo se o motorista não existir
    } catch (erro) {
      print("Erro ao buscar motorista específico: $erro");
      return null;
    }
  }
  
}