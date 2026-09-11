import 'package:cloud_firestore/cloud_firestore.dart';
import 'cliente.dart';

class ClientRepository {
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
    try {
      // Telefone é único, se já ta registrado, não cria outro
      final query = await _db
        .collection('clientes')
        .where('telefone', isEqualTo: telefone)
        .limit(1)
        .get();

      if (query.docs.isNotEmpty) {
        print("AVISO: Já existe um cliente cadastrado com o telefone $telefone!");
        return;
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
      
      print("SUCESSO: Cliente $nome salvo no banco de dados!");
    } catch (erro) {
      print("ERRO ao salvar cliente: $erro");
    }
  }

  // Retorna a lista com todos os clientes
  Future<List<Cliente>> buscarClientes() async {
    try {
      final querySnapshot = await _db.collection('clientes').get();
  
      return querySnapshot.docs.map((doc) {
      return Cliente.fromMap(doc.data(), doc.id);
    }).toList();
    } catch (erro) {
      print("Erro ao buscar clientes: $erro");
      return [];
    }
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
      print("Erro ao buscar cliente específico: $erro");
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