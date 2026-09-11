import 'package:cloud_firestore/cloud_firestore.dart';
import 'entrega.dart';

class EntregaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarEntrega({
    required String dataEntrega,
    required String idMotorista,
    required String nomeMotorista,
    required String idCliente,
    required String nomeCliente,
    required String cidadeCliente,
    required int quantidadeSacos,
    required double precoUnitario,
    required double valorPago,
    required double valorPendente,
    required String formaPagamento,
    required bool pago,
    required bool entregue,
    required String observacao,
  }) async {
    try {
      // doc() vazio faz com que o Firebase crie um id único
      final docRef = _db.collection('entregas').doc();

      await docRef.set({
        "id": docRef.id,
        "dataEntrega": dataEntrega,
        "motorista": {
          "id": idMotorista,
          "nome": nomeMotorista,
        },
        "cliente": {
          "id": idCliente,
          "nome": nomeCliente,
          "cidade": cidadeCliente,
        },
        "quantidadeSacos": quantidadeSacos,
        "financeiro": {
          "precoUnitario": precoUnitario,
          "valorTotal": quantidadeSacos * precoUnitario, // Já faz o cálculo
          "valorPago": valorPago,
          "valorPendente": valorPendente,
        },
        "formaPagamento": formaPagamento,
        "status": {
          "pago": pago,
          "entregue": entregue,
        },
        "observacao": observacao
      });
      
      print("SUCESSO: Nova entrega registrada perfeitamente!");
    } catch (erro) {
      print("ERRO ao salvar a entrega: $erro");
    }
  }

  // Ouve todas as entregas em tempo real
  Stream<List<Entrega>> ouvirEntregas() {
    return _db.collection('entregas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Entrega.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Procura por id
  Future<Map<String, dynamic>?> buscarEntregaPorId(String idEntrega) async {
    try {
      final docSnap = await _db.collection('entregas').doc(idEntrega).get();
      
      if (docSnap.exists) {
        final dados = docSnap.data()!;
        dados['id'] = docSnap.id;
        return dados;
      }
      return null;
    } catch (erro) {
      print("Erro ao buscar a entrega: $erro");
      return null;
    }
  }

  // Ouve as entregas de um cliente em tempo real
  Stream<List<Entrega>> ouvirEntregasDoCliente(String idCliente) {
    return _db.collection('entregas')
      .where('cliente.id', isEqualTo: idCliente)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Entrega.fromMap(doc.data(), doc.id);
        }).toList();
      });
  }
}